// Copyright (c) 2017 VMware, Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

*** Settings ***
Documentation  Harbor BATs
Resource  ../../resources/Util.robot
Suite Setup  Nightly Test Setup  ${ip}  ${SSH_PWD}  ${HARBOR_PASSWORD}  ${ip1}
Suite Teardown  Collect Nightly Logs  ${ip}  ${SSH_PWD}  ${ip1}
Default Tags  Nightly

*** Variables ***
${HARBOR_URL}  https://${ip}
${SSH_USER}  root
${HARBOR_ADMIN}  admin

*** Test Cases ***
Test Case - Vulnerability Data Not Ready
#This case must run before vulnerability db ready
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Go Into Project  library
    Vulnerability Not Ready Project Hint
    Switch To Configure
    Go To Vulnerability Config
    Vulnerability Not Ready Config Hint

Test Case - Read Only Mode
    Init Chrome Driver    
    ${d}=   Get Current Date    result_format=%m%s			
    Create An New Project With New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=tester${d}  newPassword=Test1@34  comment=harbor  projectname=project${d}  public=true
    
    Enable Read Only
    Cannot Push image  ${ip}  tester${d}  Test1@34  project${d}  busybox:latest

    Disable Read Only
    Push image  ${ip}  tester${d}  Test1@34  project${d}  busybox:latest
    Close Browser

Test Case - Create An New User
    Init Chrome Driver    
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Close Browser

Test Case - Sign With Admin
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Close Browser

Test Case - Update User Comment
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Update User Comment  Test12#4
    Logout Harbor

Test Case - Update Password
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Change Password  Test1@34  Test12#4
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  tester${d}  Test12#4
    Close Browser
	
Test Case - Create An New Project
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Create An New Project  test${d}
    Close Browser

Test Case - User View Projects
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Create An New Project  test${d}1
    Create An New Project  test${d}2
    Create An New Project  test${d}3
    Switch To Log
    Capture Page Screenshot  UserViewProjects.png
    Wait Until Page Contains  test${d}1
    Wait Until Page Contains  test${d}2
    Wait Until Page Contains  test${d}3
    Close Browser	
	
Test Case - Push Image
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Create An New Project  test${d}

    Push image  ${ip}  tester${d}  Test1@34  test${d}  hello-world:latest
    Go Into Project  test${d}
    Wait Until Page Contains  test${d}/hello-world

Test Case - User View Logs
    Init Chrome Driver
    ${d}=   Get Current Date    result_format=%m%s
				
    Create An New Project With New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=tester${d}  newPassword=Test1@34  comment=harbor  projectname=project${d}  public=true

    Push image  ${ip}  tester${d}  Test1@34  project${d}  busybox:latest
    Pull image  ${ip}  tester${d}  Test1@34  project${d}  busybox:latest
    
    Go Into Project  project${d}
    Delete Repo  project${d}
	
    Go To Project Log
    Advanced Search Should Display
	
    Do Log Advanced Search
    Close Browser
	
Test Case - Manage project publicity
    Init Chrome Driver
    ${d}=    Get Current Date  result_format=%m%s

    Create An New User  url=${HARBOR_URL}  username=usera${d}  email=usera${d}@vmware.com  realname=usera${d}  newPassword=Test1@34  comment=harbor
    Logout Harbor
    Create An New User  url=${HARBOR_URL}  username=userb${d}  email=userb${d}@vmware.com  realname=userb${d}  newPassword=Test1@34  comment=harbor
    Logout Harbor

    Sign In Harbor  ${HARBOR_URL}  usera${d}  Test1@34
    Create An New Project  project${d}  public=true

    Push image  ${ip}  usera${d}  Test1@34  project${d}  hello-world:latest
    Pull image  ${ip}  userb${d}  Test1@34  project${d}  hello-world:latest

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  userb${d}  Test1@34
    Project Should Display  project${d}
    Search Private Projects
    Project Should Not Display  project${d}

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  usera${d}  Test1@34
    Make Project Private  project${d}

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  userb${d}  Test1@34
    Project Should Not Display  project${d}
    Cannot Pull image  ${ip}  userb${d}  Test1@34  project${d}  hello-world:latest

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  usera${d}  Test1@34
    Make Project Public  project${d}

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  userb${d}  Test1@34
    Project Should Display  project${d}
    Close Browser

Test Case - Project Level Policy Public
    Init Chrome Driver
    ${d}=  Get Current Date    result_format=%m%s
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Create An New Project  project${d}
    Go Into Project  project${d}
    Goto Project Config
    Click Project Public
    Save Project Config
    # Verify
    Public Should Be Selected 
    Back To Projects
    # Project${d}  default should be private
    # Here logout and login to try avoid a bug only in autotest
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD} 
    Filter Object  project${d}
    Project Should Be Public  project${d}
    Close Browser

Test Case - Project Level Policy Content Trust
    Init Chrome Driver
    ${d}=  Get Current Date    result_format=%m%s
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Create An New Project  project${d}
    Push Image  ${ip}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}  project${d}  hello-world:latest
    Go Into Project  project${d}
    Goto Project Config
    Click Content Trust
    Save Project Config
    # Verify
    Content Trust Should Be Selected
    Cannot Pull Unsigned Image  ${ip}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}  project${d}  hello-world:latest
    Close Browser

Test Case - Edit Project Creation
    # Create normal user and login
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest

    Project Creation Should Display
    Logout Harbor

    Sleep  3
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Set Pro Create Admin Only
    Logout Harbor

    Sign In Harbor  ${HARBOR_URL}  tester${d}  Test1@34
    Project Creation Should Not Display
    Logout Harbor

    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Set Pro Create Every One
    Close browser

Test Case - Edit Self-Registration
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Disable Self Reg
    Logout Harbor

    Sign Up Should Not Display

    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Switch To Configure
    Self Reg Should Be Disabled
    Sleep  1

    # Restore setting
    Enable Self Reg
    Close Browser

Test Case - Edit Email Settings
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}

    Switch To Email
    Config Email

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}

    Switch To Email
    Verify Email

    Close Browser

Test Case - Edit Token Expire
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Switch To System Settings
    Modify Token Expiration  20
    Logout Harbor

    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Switch To System Settings
    Token Must Be Match  20

    #reset to default
    Modify Token Expiration  30
    Close Browser

Test Case - Scan A Tag In The Repo
    Init Chrome Driver
    ${d}=  get current date  result_format=%m%s
    Create An New Project With New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=tester${d}  newPassword=Test1@34  comment=harbor  projectname=project${d}  public=false
    Push Image  ${ip}  tester${d}  Test1@34  project${d}  hello-world
    Go Into Project  project${d}
    Go Into Repo  project${d}/hello-world
    Scan Repo  latest  Succeed
    Summary Chart Should Display  latest
    Pull Image  ${ip}  tester${d}  Test1@34  project${d}  hello-world
    # Edit Repo Info
    Close Browser

Test Case - Scan As An Unprivileged User
    Init Chrome Driver
    ${d}=    get current date    result_format=%m%s
    Push Image  ${ip}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}  library  hello-world
    Create An New User  ${HARBOR_URL}  user${d}  user${d}@vmware.com  user${d}  Test1@34  harbor
    Go Into Project  library
    Go Into Repo  hello-world
    Select Object  latest
    Scan Is Disabled
    Close Browser
##
Test Case - Scan Image With Empty Vul
    Init Chrome Driver
    Push Image  ${ip}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}  library  hello-world
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Go Into Project  library
    Go Into Repo  hello-world
    Scan Repo  latest  Succeed
    Move To Summary Chart
    Wait Until Page Contains  Unknow
    Close Browser
###
Test Case - Disable Scan Schedule
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Switch To Configure
    Go To Vulnerability Config
    Disable Scan Schedule
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Switch To Configure
    Go To Vulnerability Config
    Page Should Contain  None
    Close Browser
###
Test Case - Manual Scan All
    Init Chrome Driver
    Push Image  ${ip}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}  library  redis
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Switch To Configure
    Go To Vulnerability Config
    Trigger Scan Now
    Back To Projects
    Go Into Project  library
    Go Into Repo  redis
    Summary Chart Should Display  latest
    Close Browser
#
Test Case - Project Level Image Serverity Policy 
    Init Chrome Driver
    Push Image  ${ip}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}  library  haproxy
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Go Into Project  library
    Go Into Repo  haproxy
    Scan Repo  latest  Succeed
    Back To Projects
    Go Into Project  library
    Set Vulnerabilty Serverity  0
    Cannot pull image  ${ip}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}  library  haproxy
    Close Browser

Test Case - Scan Image On Push
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Go Into Project  library
    Goto Project Config
    Enable Scan On Push
    Push Image  ${ip}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}  library  memcached 
    Back To Projects
    Go Into Project  library
    Go Into Repo  memcached
    Summary Chart Should Display  latest
    Close Browser

Test Case - Manage Project Member
    Init Chrome Driver
    ${d}=    Get current Date  result_format=%m%s

    Create An New Project With New User  url=${HARBOR_URL}  username=alice${d}  email=alice${d}@vmware.com  realname=alice${d}  newPassword=Test1@34  comment=harbor  projectname=project${d}  public=false
    Push image  ip=${ip}  user=alice${d}  pwd=Test1@34  project=project${d}  image=hello-world
    Logout Harbor
    Create An New User  url=${HARBOR_URL}  username=bob${d}  email=bob${d}@vmware.com  realname=bob${d}  newPassword=Test1@34  comment=habor
    Logout Harbor
    Create An New User  url=${HARBOR_URL}  username=carol${d}  email=carol${d}@vmware.com  realname=carol${d}  newPassword=Test1@34  comment=harbor
    Logout Harbor

    User Should Not Be A Member Of Project  bob${d}  Test1@34  project${d}
    Manage Project Member  alice${d}  Test1@34  project${d}  bob${d}  Add
    User Should Be Guest  bob${d}  Test1@34  project${d}
    Change User Role In Project  alice${d}  Test1@34  project${d}  bob${d}  Developer
    User Should Be Developer  bob${d}  Test1@34  project${d}
    Change User Role In Project  alice${d}  Test1@34  project${d}  bob${d}  Admin
    User Should Be Admin  bob${d}  Test1@34  project${d}  carol${d}
    Manage Project Member  alice${d}  Test1@34  project${d}  bob${d}  Remove
    User Should Not Be A Member Of Project  bob${d}  Test1@34  project${d}
    User Should Be Guest  carol${d}  Test1@34  project${d}

    Close Browser

Test Case - Delete A Project
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New Project With New User  ${HARBOR_URL}  tester${d}  tester${d}@vmware.com  tester${d}  Test1@34  harobr  project${d}  false
    Push Image  ${ip}  tester${d}  Test1@34  project${d}  hello-world  
    Project Should Not Be Deleted  project${d}
    Go Into Project  project${d}
    Delete Repo  project${d}
    Back To projects
    Project Should Be Deleted  project${d}
    Close Browser

Test Case - Delete Multi Project
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s 
    Create An New User  ${HARBOR_URL}  test${d}  test${d}@vmware.com  test${d}  Test1@34  harbor
    Create An New Project  projecta${d}
    Create An New Project  projectb${d}
    Push Image  ${ip}  test${d}  Test1@34  projecta${d}  hello-world
    Filter Object  project
    Multi-delete Object  projecta  projectb
    Partly Success
    # Verify delete project with image should not be deleted directly
    Page Should Contain  projecta${d}
    Page Should Not Contain  projectb${d}
    Close Browser

Test Case - Delete Multi User
    Init Chrome Driver
    ${d}=   Get Current Date    result_format=%m%s
    Create An New User  ${HARBOR_URL}  deletea${d}  testa${d}@vmware.com  test${d}  Test1@34  harbor
    Logout Harbor
    Create An New User  ${HARBOR_URL}  deleteb${d}  testb${d}@vmware.com  test${d}  Test1@34  harbor
    Logout Harbor
    Create An New User  ${HARBOR_URL}  deletec${d}  testc${d}@vmware.com  test${d}  Test1@34  harbor
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  admin  Harbor12345
    Switch To User Tag
    Filter Object  delete
    Multi-delete Object  deletea  deleteb  deletec
    # Assert delete 
    Delete Success  
    Sleep  1
    # Filter object  delete
    Page Should Not Contain  deletea
    Close Browser

Test Case - Delete Multi Repo
    Init Chrome Driver
    ${d}=   Get Current Date    result_format=%m%s
    Create An New User  ${HARBOR_URL}  test${d}  test${d}@vmware.com  test${d}  Test1@34  harbor
    Create An New Project  project${d}
    Push Image  ${ip}  test${d}  Test1@34  project${d}  hello-world  
    Push Image  ${ip}  test${d}  Test1@34  project${d}  busybox
    Sleep  2
    Go Into Project  project${d}
    Multi-delete Object  hello-world  busybox
    # Verify
    Delete Success
    Close Browser

Test Case - Delete Multi Tag
    Init Chrome Driver
    ${d}=   Get Current Date    result_format=%m%s
    Create An New User  ${HARBOR_URL}  test${d}  test${d}@vmware.com  test${d}  Test1@34  harbor
    Create An New Project  project${d}
    Push Image With Tag  ${ip}  test${d}  Test1@34  project${d}  redis  3.2.10-alpine  3.2.10-alpine
    Push Image With Tag  ${ip}  test${d}  Test1@34  project${d}  redis  4.0.7-alpine  4.0.7-alpine
    Sleep  2
    Go Into Project  project${d}
    Go Into Repo  redis
    Multi-delete object  3.2.10-alpine  4.0.7-alpine
    # Verify
    Delete Success
    Close Browser

Test Case - Delete Multi Member
    Init Chrome Driver
    ${d}=   Get Current Date    result_format=%m%s
    Create An New User  ${HARBOR_URL}  testa${d}  testa${d}@vmware.com  test${d}  Test1@34  harbor
    Logout Harbor
    Create An New User  ${HARBOR_URL}  testb${d}  testb${d}@vmware.com  test${d}  Test1@34  harbor
    Logout Harbor
    Create An New User  ${HARBOR_URL}  test${d}  test${d}@vmware.com  test${d}  Test1@34  harbor
    Create An New Project  project${d}
    Go Into Project  project${d}
    Switch To Member
    Add Guest Member to project  testa${d}
    Add Guest Member to project  testb${d}
    Multi-delete Member  testa${d}  testb${d}
    Delete Success
    Page Should Not Contain  testa${d}
    Close Browser
    
Test Case - Assign Sys Admin
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}
    Switch to User Tag
    Assign User Admin  tester${d}
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  tester${d}  Test1@34
    Administration Tag Should Display
    Close Browser

Test Case - Admin Push Signed Image
    Enable Notary Client

    ${rc}  ${output}=  Run And Return Rc And Output  docker pull hello-world:latest
    Log  ${output}
		
    Push image  ${ip}  ${HARBOR_ADMIN}  ${HARBOR_PASSWORD}  library  hello-world:latest
    ${rc}  ${output}=  Run And Return Rc And Output  ./tests/robot-cases/Group9-Content-trust/notary-push-image.sh ${ip}
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0

    ${rc}  ${output}=  Run And Return Rc And Output  curl -u admin:Harbor12345 -s --insecure -H "Content-Type: application/json" -X GET "https://${ip}/api/repositories/library/tomcat/signatures"
    Log To Console  ${output}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  sha256

Test Case - View Scan Results
    Init Chrome Driver
    ${d}=  get current date  result_format=%m%s
    Create An New Project With New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=tester${d}  newPassword=Test1@34  comment=harbor  projectname=project${d}  public=false
    Push Image  ${ip}  tester${d}  Test1@34  project${d}  tomcat
    Go Into Project  project${d}
    Go Into Repo  project${d}/tomcat
    Scan Repo  latest  Succeed
    Summary Chart Should Display  latest
    View Repo Scan Details
    Close Browser

Test Case - View Scan Error
    Init Chrome Driver
    ${d}=  get current date  result_format=%m%s
    Create An New Project With New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=tester${d}  newPassword=Test1@34  comment=harbor  projectname=project${d}  public=false
    Push Image  ${ip}  tester${d}  Test1@34  project${d}  vmware/photon:1.0
    Go Into Project  project${d}
    Go Into Repo  project${d}/vmware/photon
    Scan Repo  1.0  Fail
    View Scan Error Log
    Close Browser

#Test Case - OVA reboot
#    Reboot VM  ${vm_name}  ${vc_host}  ${vc_user}  ${vc_password}
#    Wait for Harbor Ready  https  ${ip}

#Test Case - OVA reset
#    Reset VM  ${vm_name}  ${vc_host}  ${vc_user}  ${vc_password}
#    Wait for Harbor Ready  https  ${ip}
