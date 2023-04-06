module lending::vault {
    use std::option;

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct CCoin<phantom CoinType> has drop {}

    struct Pool<phantom CoinType> has key, store {
        id: UID,
        token: Balance<CoinType>,
        c_token: Balance<CCoin<CoinType>>,
        exchange_rate: u64,
        treasury_cap: TreasuryCap<CCoin<CoinType>>
    }

    const WRONG_RATE: u8 = 0;

    public fun create<CoinType, CoinPool: drop>(
        _: CoinPool,
        exchange_rate: u64,
        decimals: u8,
        symbol: vector<u8>,
        name: vector<u8>,
        description: vector<u8>,
        ctx: &mut TxContext
    ) {
        let (treasury_cap, metadata) = coin::create_currency(
            CCoin<CoinType> {},
            decimals,
            symbol,
            name,
            description,
            option::none(),
            ctx
        );
        transfer::public_freeze_object(metadata);

        let pool = Pool<CoinType> {
            id: object::new(ctx),
            token: balance::zero<CoinType>(),
            c_token: balance::zero<CCoin<CoinType>>(),
            exchange_rate,
            treasury_cap
        };

        transfer::share_object(pool);
    }

    public entry fun deposit<CoinType>(
        pool: &mut Pool<CoinType>,
        coin: Coin<CoinType>,
        ctx: &mut TxContext
    ) {
        let input = coin::into_balance(coin);
        let input_amt = balance::value(&input);

        balance::join(&mut pool.token, input);
        let ouput_amt = input_amt * pool.exchange_rate / 100;

        coin::mint_and_transfer<CCoin<CoinType>>(&mut pool.treasury_cap, ouput_amt, tx_context::sender(ctx), ctx);
    }

    public entry fun transfer<CoinType>(c: coin::Coin<CCoin<CoinType>>, recipient: address) {
        transfer::public_transfer(c, recipient)
    }
}
