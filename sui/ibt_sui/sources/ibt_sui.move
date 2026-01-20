module ibt_sui::ibt {
    use sui::coin::{Self, Coin, TreasuryCap, CoinMetadata};
    use sui::object;
    use std::option;
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct IBT has drop {}

    struct BridgeBurnEvent has copy, drop {
        sender: address,
        amount: u64,
        eth_address: vector<u8>,
        nonce: u64,
    }

    /// Shared bridge state
    struct BridgeState has key {
        id: object::UID,
        nonce: u64,
    }

    fun init(witness: IBT, ctx: &mut TxContext) {
        let (cap, metadata) = coin::create_currency<IBT>(
            witness,
            9,
            b"IBT",
            b"Introduction to Blockchain Technologies",
            b"IBT token that can be bridged between eth and sui",
            option::none(),
            ctx
        );

        transfer::public_transfer(cap, tx_context::sender(ctx));
        transfer::public_transfer(metadata, tx_context::sender(ctx));

        let state = BridgeState { id: object::new(ctx), nonce: 0 };
        transfer::share_object(state);
    }

    public entry fun mint(
        cap: &mut TreasuryCap<IBT>,
        recipient: address,
        amount: u64,
        ctx: &mut TxContext
    ) {
        let c: Coin<IBT> = coin::mint<IBT>(cap, amount, ctx);
        transfer::public_transfer(c, recipient);
    }

    public entry fun bridge_to_eth(
        state: &mut BridgeState,
        cap: &mut TreasuryCap<IBT>,
        c: Coin<IBT>,
        eth_address: vector<u8>,
        ctx: &mut TxContext
    ) {
        let amount = coin::burn<IBT>(cap, c);

        event::emit(BridgeBurnEvent {
            sender: tx_context::sender(ctx),
            amount,
            eth_address,
            nonce: state.nonce,
        });

        state.nonce = state.nonce + 1;
    }
}
