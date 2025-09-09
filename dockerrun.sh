# docker run -it -v `pwd`:/host rayans2/cs598ape /bin/bash

# docker run --rm -it --mount type=bind,source="$(realpath 598APE-HW1)",target=/host --workdir /host rayans2/cs598ape /bin/bash

docker run --rm -it -v `pwd`:/host -w /host rayans2/cs598ape /bin/bash