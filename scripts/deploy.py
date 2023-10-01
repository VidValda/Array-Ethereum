from brownie import ContratoInversion, MockV3Aggregator, config, network
from scripts.helpful_scripts import get_account, deploy_mocks, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from web3 import Web3

def deploy_inversor():
    account = get_account()
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    inversor = ContratoInversion.deploy(
        price_feed_address,
        {"from": account}, 
        publish_source=config["networks"][network.show_active()].get("verify"),
        )
    print(f"Inversor deployed to {inversor.address}")
    return inversor

def main():
    deploy_inversor()