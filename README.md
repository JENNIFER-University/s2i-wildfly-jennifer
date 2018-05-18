
# Wildfly s2i builder image with JENNIFER Agent
This sample repo can be used as a base create enhanced builder image with JENNIFER java agent and Wildfly 12 for OpenShift V3

You can read the tutorial at [JENNIFER University](https://edu.jennifersoft.com/articles/jennifer-5/java-agent-5/using-jennifer-with-red-hat-openshift)


## Requirements

* JENNIFER Java Agent installation pacakge
* [Source To Image (S2I)](https://github.com/openshift/source-to-image)
* [OC cli](https://docs.openshift.com/enterprise/3.1/cli_reference/get_started_cli.html)

### Usage

* Clone this repo 

```
git clone https://github.com/JENNIFER-University/s2i-wildfly-jennifer
```

* Download JENNIFER agent pacakge and move the package to s2i-wildfly-jennifer directory
* Modify ```contrib/jennifer.conf`` and set server_address to point to your JENNIFER data server ip addres

* Create the builder image

To create a builder image called jennifer-oc-builder execute
```
cd s2i-wildfly-jennifer 
docker build -t jennifer-oc-builder .
```

* Create the Application image 

To build a [simple jee application](https://github.com/bparees/openshift-jee-sample) using s2i: 
```
s2i build https://github.com/bparees/openshift-jee-sample jennifer-oc-builder jennifer-oc-app
```

The result image jennifer-oc-app can then be deployed to OpenShift.