module lending::vault {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::TxContext;

    struct Pool<phantom Token, phantom CToken> has key, store {
        id: UID,
        token: Balance<Token>,
        c_token: Balance<CToken>,
        exchange_rate: u64
    }

    const WRONG_RATE: u8 = 0;

    public entry fun newPool<Token, CToken>(exchange_rate: u64, ctx: &mut TxContext) {
        // assert!(exchange_rate > 1, WRONG_RATE);
        let pool = Pool<Token, CToken> {
            id: object::new(ctx),
            token: balance::zero<Token>(),
            c_token: balance::zero<CToken>(),
            exchange_rate
        };
        transfer::share_object(pool);
    }

    public entry fun deposit<Token, CToken>(
        pool: &mut Pool<Token, CToken>,
        coin: Coin<Token>,
        _ctx: &mut TxContext
    ) {
        let input = coin::into_balance(coin);
        let input_amt = balance::value(&input);

        balance::join(&mut pool.token, input);
        let _ = input_amt * pool.exchange_rate / 100;
        // coin::mint_and_transfer(,ouput_amt,)
        // transfer::transfer()
        // TODO: mint
    }
}
