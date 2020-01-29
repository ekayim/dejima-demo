import yaml
import sys
args = sys.argv

with open("docker-compose.yml") as f:
    orchestration_setting = yaml.safe_load(f)

peers = ["p1-proxy", "p2-proxy", "p3-proxy", "p4-proxy"]
for peer in peers:
    orchestration_setting["services"][peer]["environment"][2] = "CC_METHOD={}".format(args[1])

text_data = yaml.dump(orchestration_setting, default_flow_style=False)

with open("docker-compose.yml", "w") as f:
    f.write(text_data)