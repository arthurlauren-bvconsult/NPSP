/*
    Copyright (c) 2013, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2013
* @description test trigger handler on Contact to throw an exception for error handling tests
* @group ErrorHandling
*/
@isTest
public with sharing class ERR_ParentAccountUpdater2_TEST extends TDTM_Runnable {
	
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
     TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
         
        DmlWrapper dmlWrapper = new DmlWrapper();
 
        //Querying the name in the parent account is only necessary if we are in a future.
        //It is necessary here because we are calling this class from TDTM_Runnable_TEST.
        if(System.isFuture()) {
	        List<Contact> contactsWithParentId = [select AccountId from Contact where Id in :newList];
	        List<Id> parentAccIds = new List<Id>();
	        
	        for(SObject o : contactsWithParentId) {
	        	Contact contact = (Contact)o;
	        	contact.FirstName = 'New First Name';
	        	dmlWrapper.objectsToUpdate.add(contact);
	        	parentAccIds.add(contact.AccountId);
	        }

	        List<Account> parentAccs = [select Id, Name from Account where Id in :parentAccIds];
	        for(Account acc : parentAccs) {
	            acc.Name = 'New Acc Name';
	            dmlWrapper.objectsToUpdate.add(acc);
	        }
        //If we are not in a future setting the name of the parent account does not throw a null pointer exception.	
        } else {
        	List<Contact> contactsWithParentInfo = [select Account.Id, Account.Name from Contact where Id in :newList];
        	for(SObject o : contactsWithParentInfo) {
        		Contact contact = (Contact)o;
        		contact.FirstName = 'New First Name';
        		contact.Account.Name = 'New Acc Name';
        		dmlWrapper.objectsToUpdate.add(contact.Account);
        	}
        }

        return dmlWrapper;
    }
}