from datetime import date, datetime
import math

from .generate_bdi_CO_data import GenerateBDIData_CO
import factory
from .factory_utils import Adder

# Per https://salesforce.quip.com/gLfGAPtqVzUS

Models = GenerateBDIData_CO.Models


def now():
    return datetime.now().date()


START_DATE = date(2019, 1, 1)  # Per https://salesforce.quip.com/gLfGAPtqVzUS


class MaintenancePlan(factory.Factory):
    class Meta:
        model = Models.MaintenancePlan

    id = factory.Sequence(lambda n: n + 1)
    Frequency = 5
    GenerationTimeframe = 10
    StartDate = now()
    NextSuggestedMaintenanceDate = now()


class DataImport(factory.Factory):
    class Meta:
        model = Models.npsp__DataImport__c

    class Params:
        counter = "Adder not set"

    id = factory.Sequence(lambda n: n + 1)
    npsp__Donation_Amount__c = factory.LazyAttribute(lambda o: o.counter(1) * 100)
    npsp__Donation_Date__c = now()
    npsp__GAU_Allocation_1_Percent__c = 10
    npsp__CO1_Date__c = now()
    npsp__CO1_currency__c = 100
    npsp__CO1_Number__c = 1
    npsp__CO1_Picklist__c = factory.Sequence(lambda i: f"Option{(i%4) + 1}")
    npsp__CO1_Phone__c = 123
    npsp__CO1_textarea__c = "Long text"
    npsp__CO1_url__c = "http://www.url.com/"
    npsp__CO1_text2__c = factory.LazyAttribute(lambda o: f"text{o.counter(0)}")
    npsp__CO1_Currency2__c = 200   # ## CHECK THIS ONE IS FIXED
    npsp__CO3_Text__c = factory.LazyAttribute(lambda o: f"text{o.counter(0)}")
    npsp__CO3_Date__c = now()
    npsp__CO3_Currency__c = 100
    npsp__CO3_Number__c = 1
    npsp__CO3_Picklist__c = factory.Sequence(lambda i: f"Option{(i%3) + 1}")
    npsp__CO3_Phone__c = 123
    npsp__WO_MinimumCrewSize__c = 5
    npsp__WO_RecommendedCrewSize__c = 10
    npsp__WO_SuggestedMaintenanceDate__c = now()
    npsp__WO_Subject__c = factory.Sequence(lambda n: f"test{n + 1}")
    npsp__Contact1_Lastname__c = "Some Contact"
    npsp__Account1_Country__c = "Canada"
    npsp__Contact1_Title__c = "HRH"
    # npsp__ASC_Role__c = "match"
    # npsp__ASC_Amount__c = 100


class GAU(factory.Factory):
    class Meta:
        model = Models.npsp__General_Accounting_Unit__c

    id = factory.Sequence(lambda n: n + 1)


def make_records(num_records, factories):
    """Make the 4 batches of DIs described here:
    https://salesforce.quip.com/YfOpAwKbhcat
    """
    batch_size = math.floor(num_records / 4)  

    def create_batch(classname, **kwargs):
        factories.create_batch(classname, batch_size, **kwargs)

    gau = factories["GAU"].create(Name="Scholarship")
    maintenance_plan = factories["MaintenancePlan"].create()

    create_batch(
        "DataImport",
        counter=Adder(0),
        npsp__Donation_Donor__c="Account1",
        npsp__Opp_Do_Not_Automatically_Create_Payment__c=False,
        npsp__Account1_Name__c=factory.LazyAttribute(lambda o: f"Account {o.counter(0)}"),
        npsp__CO1_Text__c=factory.LazyAttribute(lambda o: f"Account {o.counter(0)}"),
        npsp__GAU_Allocation_1_GAU__c=gau.id,
        npsp__WO_MaintenancePlan__c=maintenance_plan.id,
    )
    create_batch(
        "DataImport",
        counter=Adder(0),
        npsp__Donation_Donor__c="Account1",
        npsp__Opp_Do_Not_Automatically_Create_Payment__c=False,
        npsp__Account1_Name__c=factory.LazyAttribute(lambda o: f"Account{o.counter(0)}"),
        npsp__CO1_Text__c=factory.LazyAttribute(lambda o: f"text{o.counter(0)}"),
        npsp__GAU_Allocation_1_GAU__c=gau.id,
        npsp__WO_MaintenancePlan__c=maintenance_plan.id,
    )
    create_batch(
        "DataImport",
        counter=Adder(0),
        npsp__Donation_Donor__c="Contact1",
        npsp__Opp_Do_Not_Automatically_Create_Payment__c=False,
        npsp__Contact1_Lastname__c=factory.LazyAttribute(lambda o: f"Contact {o.counter(0)}"),
        npsp__Opportunity_Contact_Role_1_Role__c="Influencer",
        npsp__CO1_Text__c=factory.LazyAttribute(lambda o: f"text{o.counter(0)}"),
        npsp__GAU_Allocation_1_GAU__c=gau.id,
        npsp__WO_MaintenancePlan__c=maintenance_plan.id,
    )
    create_batch(
        "DataImport",
        counter=Adder(0),
        npsp__Donation_Donor__c="Contact1",
        npsp__Opp_Do_Not_Automatically_Create_Payment__c=False,
        npsp__Contact1_Lastname__c=factory.LazyAttribute(lambda o: f"Contact{o.counter(0)}"),
        npsp__Opportunity_Contact_Role_1_Role__c="Influencer",
        npsp__CO1_Text__c=factory.LazyAttribute(lambda o: f"text{o.counter(0)}"),
        npsp__GAU_Allocation_1_GAU__c=gau.id,
        npsp__WO_MaintenancePlan__c=maintenance_plan.id,
    )
