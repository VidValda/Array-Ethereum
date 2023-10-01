from brownie import ContratoInversion
from scripts.deploy import deploy_inversor
from scripts.helpful_scripts import get_account

def inv():
    account = get_account()
    inversor = deploy_inversor()
    entrance_fee = inversor.getEntranceFee()
    print(f"La comisión de entrada es de {entrance_fee}")
    inversor.invertir({"from": account, "value": 1000000000000000000})
    print(f"Se ha invertido en {inversor.address}")

def retirar():
    account = get_account()
    inversor = deploy_inversor()
    inversor.retirar_inversion(1,{"from": account})
    print(f"Se ha retirado de {inversor.address}")

def main():
    inv()