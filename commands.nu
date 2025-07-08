let name = "nushell-dev"

def main [] {}

def "main build" [--watch] {
    if $watch == false {
        docker build -t $name --build-arg VARIANT=jammy . -f .devcontainer/Dockerfile
        return
    }

    try {
        watch .devcontainer/Dockerfile { || docker build -t $name --build-arg VARIANT=jammy . -f .devcontainer/Dockerfile }
    } catch { |error|
        print $error
    }
}

def "main export" [] {
    docker save ($name + ":latest") | tar -x -O */layer.tar | tar -t
}
