module lending::c_sui {
    use sui::sui;
    use sui::tx_context::TxContext;

    use lending::vault;

    /// Name of the coin
    struct CSUI has drop {}


    fun init(ctx: &mut TxContext) {
        vault::create<sui::SUI, CSUI>(
            CSUI {},
            10,
            10,
            b"CSUI",
            b"CSUI",
            b"DESC",
            ctx,
        );
    }
}
