/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group HGE
* @group-content
* @description Class holds payment services related methods.
*/
public with sharing class GE_PaymentServices {

    DataImport__c dataImportRecord;
    FabricatedCardholderNames fabricatedCardholderNames;

    public GE_PaymentServices() {}

    public GE_PaymentServices(DataImport__c dataImportRecord, String fabricatedCardholderNames) {
        this.dataImportRecord = dataImportRecord;
        this.fabricatedCardholderNames = (FabricatedCardholderNames)
            JSON.deserialize(fabricatedCardholderNames, FabricatedCardholderNames.class);
    }

    public ResponseWrapper makePurchaseCall() {
        // Create http request...
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(getEndpointRoot() + getEndpoint(ElevateEndpoints.PURCHASE));
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('jwttoken', getJwt());
        request.setHeader('sfdo.merchantids', getMerchantIds());
        request.setHeader('sfdo.username', getUsername());

        // Set the body as a JSON object...
        String purchaseCallBodyString =
            new PurchaseCallBody(dataImportRecord, fabricatedCardholderNames).getAsJson();
        request.setBody(purchaseCallBodyString);

        HttpResponse response = http.send(request);
        ResponseWrapper responseWrapper = new ResponseWrapper(response);
        System.debug(responseWrapper);
        return responseWrapper;
    }

    private enum ElevateEndpoints { PURCHASE }

    private String getEndpoint(ElevateEndpoints endpoint) {
        if (endpoint === ElevateEndpoints.PURCHASE) {
            return '/v1/payments/verified/purchase';
        }
        return null;
    }


    // TODO: Get header/secret info from payments configuration hidden sobject
    private String getEndpointRoot() {
        return 'https://7jpea5zk79.execute-api.us-west-2.amazonaws.com';
    }

    private String getJwt() {
        return 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJBcGlLZXlNYW5hZ2VyIiwiaWF0IjoxNTgzMTk2MTAxLCJleHAiOjE2MTQ3MzIxMTAsImF1ZCI6Ind3dy5leGFtcGxlLmNvbSIsInN1YiI6ImNiYXh0ZXIiLCJzZmRvLmlkIjoiMDBENmcwMDAwMDAwMDAwRUFBIiwic2Zkby5wcm9kdWN0IjoiQ1JNIiwic2Zkby5yb2xlcyI6IlBheW1lbnRzLlB1cmNoYXNlIn0.Fk2kH8occu-tEabrYALiAN16XlIUj4vpptWGs0x8eZs';
    }

    private String getMerchantIds() {
        return '47b70ca4-0f6e-4c52-819f-667ae804f9d2';
    }

    private String getUsername() {
        return 'cbaxter';
    }

    public with sharing class Metadata {
        public String campaignCode;
    }

    public with sharing class PurchaseCallBody {
        public Double amount;
        public String currencyCode;
        public String paymentMethodToken;
        public String merchantId;
        public String gatewayId;
        public String email;
        public String firstName;
        public String lastName;
        public Metadata metadata;

        private Double getAmount(DataImport__c dataImport) {
            return dataImport.Donation_Amount__c;
        }

        private String getCurrencyCode() {
            return 'USD';
        }

        private String getPaymentMethodToken(DataImport__c dataImport) {
            return dataImport.Payment_Authorization_Token__c;
        }

        private String getMerchantId() {
            return '47b70ca4-0f6e-4c52-819f-667ae804f9d2';
            // Bad merchant id below
            //return '47b70ca4-0f6e-4c52-819f-667ae804f9d3';
        }

        private String getGatewayId() {
            return 'f23da98a-c7aa-4637-962a-8c852e765e38';
        }

        private String getEmail() {
            return 'bart.simpson@example.com';
        }

        private String getFirstName(FabricatedCardholderNames names) {
            return String.isNotBlank(names.firstName) ? names.firstName : names.accountName;
        }

        private String getLastName(FabricatedCardholderNames names) {
            return String.isNotBlank(names.lastName) ? names.lastName : names.accountName;
        }

        private Metadata getMetadata(DataImport__c dataImport) {
            Metadata metadata = new Metadata();
            metadata.campaignCode = dataImport.Donation_Campaign_Name__c;

            return metadata;
        }

        public PurchaseCallBody(DataImport__c dataImport, FabricatedCardholderNames names) {
            this.amount = getAmount(dataImport);
            this.currencyCode = getCurrencyCode();
            this.paymentMethodToken = getPaymentMethodToken(dataImport);
            this.merchantId = getMerchantId();
            this.gatewayId = getGatewayId();
            this.email = getEmail();
            this.firstName = getFirstName(names);
            this.lastName = getLastName(names);
            this.metadata = getMetadata(dataImport);
        }

        public String getAsJson() {
            return JSON.serialize(this);
        }
    }

    public with sharing class ResponseWrapper {
        public Integer statusCode;
        public String status;
        public String body;

        public ResponseWrapper(HttpResponse response) {
            this.statusCode = response.getStatusCode();
            this.status = response.getStatus();
            this.body = response.getBody();
        }
    }

    public with sharing class FabricatedCardholderNames {
        public String firstName;
        public String lastName;
        public String accountName;
    }
}