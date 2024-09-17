
function dkka {
  docker kill $(docker ps | grep -v CONTAINER | awk '{print $1}')
}

function dkps {
  docker ps
}

function dkk {
	docker kill $(docker ps | grep -v CONTAINER | fzf --height 20 -m | awk '{print $1}')
}

function dkrm {
	docker image rm $@ $(docker image ls| grep -v REPOSITORY| fzf --height 30 -m| awk '{print $1":"$2}')
}

