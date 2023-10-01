from scripts.helpful_scripts import get_account
from scripts.deploy import deploy_inversor

def test_can_invert_and_retire():
    account = get_account()
    inversor = deploy_inversor()
    entrance_fee = inversor.getEntranceFee()
    tx1 = inversor.invertir(account,{"from": account, "value": entrance_fee})
    tx1.wait(1)
    assert inversor.getInversionesEth(1,{ "from": account }) == entrance_fee
    print("a")
    tx2 = inversor.retirar_inversion(1,{"from": account})
    tx2.wait(1)
    assert inversor.getInversionesEth(1,{ "from": account }) == 0
    print("a")