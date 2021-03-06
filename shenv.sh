#!/bin/bash

function shenv() {
    export SHENV_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/shenv"
    export SHENV_CONFIGS_PATH="$SHENV_CONFIG_PATH/configs"

    mkdir -p $SHENV_CONFIG_PATH
    mkdir -p $SHENV_CONFIGS_PATH

    cli_name='shenv'
    author='Emerson Max de Medeiros Silva'
    version='1.0'

    function cli_help() {
        echo "Usage: $cli_name [command]

Shell config manager

commands:
    use        Use config
    edit       Edit a config
    list       List all available configs
    help       Show this help
    version    Show version
"
    }

    if [[ $# < 1 ]]
    then
        cli_help
        return 1
    fi

    function get_shenvrc_path() {
        curpath="$1"
        if [[ $curpath = '/' ]]
        then
            return
        fi

        shenvrc="$curpath/.shenvrc"
        if [[ -f $shenvrc ]]
        then
            echo $shenvrc
            return
        fi

        get_shenvrc_path $(dirname $curpath)
    }

    function use_cmd() {
        if [[ $# == 0 ]]
        then
            shenvrc_path=$(get_shenvrc_path $PWD)
            if [[ ! -f $shenvrc_path ]]
            then
                echo "Can't find .shenvrc"
                return 1
            fi

            config="$(cat $shenvrc_path)"
        else
            config="$1"
        fi

        if [[ -z ${config} ]]
        then
            echo "config cannot be empty"
            return 1
        fi

        shenv_config="$SHENV_CONFIGS_PATH/$config"
        if [[ ! -f $shenv_config ]]
        then
            echo "Config $config not found"
            return 1
        fi

        echo -n "Sourcing $config... "
        source $shenv_config
        echo "Done."
    }

    function edit_cmd() {
        if [[ $# == 0 ]]
        then
            echo "Usage: $cli_name edit <config>"
            return 1
        fi

        config="$1"
        config_path="$SHENV_CONFIGS_PATH/$config"

        if [[ -z ${EDITOR+x} ]]
        then
            echo 'Variable $EDITOR has not been defined.'
            echo 'Using vi by default.'
            EDITOR='vi'
        fi

        $EDITOR $config_path
    }

    function list_cmd() {
        for config_path in $SHENV_CONFIGS_PATH/*
        do
            if [[ ! -f "$config_path" ]]
            then
                continue
            fi

            config=$(basename $config_path)
            echo $config
        done
    }

    function help_cmd() {
        cli_help
        return 0
    }

    function version_cmd() {
        echo "$cli_name $version"
    }

    action="$1"
    shift 1
    case $action in
        use)
            use_cmd $@
            ;;
        edit)
            edit_cmd $@
            ;;
        list)
            list_cmd
            ;;
        help)
            help_cmd
            ;;
        version)
            version_cmd
            ;;
        *)
            echo -e "Invalid command '$action'\n"
            cli_help
            ;;
    esac
}
