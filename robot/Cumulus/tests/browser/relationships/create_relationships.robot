*** Settings ***

Resource        robot/Cumulus/resources/NPSP.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Cumulus/resources/ContactPageObject.py
...             robot/Cumulus/resources/AccountPageObject.py
...             robot/Cumulus/resources/RelationshipPageObject.py
...             robot/Cumulus/resources/NPSP.py
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Delete Records and Close Browser

***Keywords***

Capture Screenshot on Failure
    Run Keyword If Test Failed  Capture Page Screenshot

Setup Test Data
    &{contact1} =                        API Create Contact    Email=automation@example.com
    Store Session Record                 Account               &{contact1}[AccountId]
    Set suite variable                   &{contact1}
    &{contact2} =                        API Create Contact
    Store Session Record                 Account               &{contact2}[AccountId]
    Set suite variable                   &{contact2}

*** Test Cases ***

Create Relationships for contacts
    [Documentation]                      Create 2 contacts with API which inturn creates 2 household accounts.
    ...                                  Open contact2 record and create a new relationship with contact 1.
    ...                                  Verify the parent-child relationship is correctly established.

    [tags]                              W-037650                                                    feature:Relationships

    Go To Page                          Details                                                     Contact                                               object_id=&{contact2}[Id]
    Select Tab                          Related
    Wait Until Loading Is Complete
    Click Related List Button           Relationships                                               New
    Wait For Modal                      New                                                         Relationship

    Populate Modal Form
    ...                                 Related Contact=&{contact1}[FirstName] &{contact1}[LastName]
    ...                                 Type=Parent
    Click Modal Button                  Save
    Current Page Should Be              Details                                                     Contact
    Validate Relation Status Message    &{contact1}[FirstName] &{contact1}[LastName]
    ...                                 &{contact2}[FirstName] &{contact2}[LastName]
    ...                                 Parent

    Click More Actions Button
    # Click Link                          link=Show more actions
    Click Link                          link=Relationships Viewer
    Wait Until Loading Is Complete
    Capture Page Screenshot
    Go To Page                          Details                                                     Contact                                               object_id=&{contact1}[Id]
    Current Page Should Be              Details                                                     Contact

    Select Tab                          Related
    Validate Relation Status Message    &{contact2}[FirstName] &{contact2}[LastName]
    ...                                 &{contact1}[FirstName] &{contact1}[LastName]
    ...                                 Child

    # Load Related List                   Relationships
    Click Related Table Item Link       Relationships                                               &{contact2}[FirstName] &{contact2}[LastName]

    Current Page Should Be              Details                                                     npe4__Relationship__c
    ${id}                               Get Current Record Id
    Save Current Record ID For Deletion  npe4__Relationship__c

