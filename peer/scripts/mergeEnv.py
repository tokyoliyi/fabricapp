#!/usr/bin/env python
#-*-coding:utf-8-*-
import os
# 处理逻辑
# shell script 是按行执行的
# 后续的行值虽然会覆盖前面相同的定义,但是,如果前面已经引用过定义的行值,那么后续覆盖,并不会替换到引用的位置的值
# 我只是对 python 比较熟悉,所以这里使用 python 来处理 shell scripts
# 以 global.env 中的数据为基准,如果 local.env 中有相同 key 定义,那么就替换掉,如果 local.env 中的 key 没有在 global.env
# 中找到,就追加到 global.env 中
# 对 user.env 的处理逻辑也是这样的
# 以上算法是有 bug 的 ->
# 如果 a 文件先定义了一个变量 vara=apple
# b 文件中定义了另外一个变量 varb=pie
# b 中重新定义了 vara=$varb_something
# 算法在 b 中看到了 vara,在 a 中找到了 vara,就把 vara 替换成了 $varb_someting
# 就导致了 varb 的值在这个时候实际还是未定义的.

GLOBAL_ENV_FILE = "/tmp/global.env"
LOCAL_ENV_FILE = "/tmp/local.env"
USER_ENV_FILE = "/tmp/user.env"

RESULT_FILE = "/tmp/env.sh"

def read_file(path):
    with open(path, 'r') as f:
        lines = f.readlines()
    lines = clean(lines)
    return lines

def write_shell_file(lines):
    shebang = "#!/bin/bash" + os.linesep
    with open(RESULT_FILE, 'w') as f:
        f.write(shebang)
        for line in lines:
            # line = f"export ${line[0]}=${line[1]}${LINESEP}"
            # why we don't use f string format?
            # we don't know which python version is used by client os
            line = "export " + line[0] + "=" + line[1] + os.linesep
            f.write(line)


def clean(lines):
    lines = [x.strip() for x in lines]
    result = []
    for line in lines:
        if line.startswith('export') and '=' in line:
            line = line.replace('export', '')
            line = line.strip()
            line = line.split('=', 1)
            result.append(line)

    return result

def merge(base, patch):
    append = []
    for p in patch:
        key = p[0]
        val = p[1]
        found = False
        for idx, b in enumerate(base[:]):
            if key == b[0]:
                print('Replace', key, b[1], '->', val)
                found = True
                b[1] = val
                base[idx] = b

        if not found:
            append.append(p)

    if append:
        base.extend(append)

    return base

def merge_envs():
    base_envs = read_file(GLOBAL_ENV_FILE)
    local_envs = read_file(LOCAL_ENV_FILE)
    base_envs = merge(base_envs, local_envs)

    # user.env maybe not exist
    # we need to check it
    if os.path.exists(USER_ENV_FILE):
        user_envs = read_file(USER_ENV_FILE)
        merge(base_envs, user_envs)

    write_shell_file(base_envs)

if __name__ == "__main__":
    merge_envs()
