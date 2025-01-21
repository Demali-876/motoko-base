/// Low-level interface to the Internet Computer.
///
/// **WARNING:** This low-level API is **experimental** and likely to change or even disappear.

import Prim "mo:⛔";

module {

  /// Calls ``canister``'s update or query function, `name`, with the binary contents of `data` as IC argument.
  /// Returns the response to the call, an IC _reply_ or _reject_, as a Motoko future:
  ///
  /// * The message data of an IC reply determines the binary contents of `reply`.
  /// * The error code and textual message data of an IC reject determines the future's `Error` value.
  ///
  /// Note: `call` is an asynchronous function and can only be applied in an asynchronous context.
  ///
  /// Example:
  /// ```motoko no-repl
  /// import IC "mo:base/ExperimentalInternetComputer";
  /// import Principal "mo:base/Principal";
  ///
  /// let ledger = Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai");
  /// let method = "decimals";
  /// let input = ();
  /// type OutputType = { decimals : Nat32 };
  ///
  /// let rawReply = await IC.call(ledger, method, to_candid(input)); // serialized Candid
  /// let output : ?OutputType = from_candid(rawReply); // { decimals = 8 }
  /// ```
  ///
  /// [Learn more about Candid serialization](https://internetcomputer.org/docs/current/motoko/main/reference/language-manual#candid-serialization)
  public let call : (canister : Principal, name : Text, data : Blob) -> async (reply : Blob) = Prim.call_raw;

  /// Given computation, `comp`, counts the number of actual and (for IC system calls) notional WebAssembly
  /// instructions performed during the execution of `comp()`.
  ///
  /// More precisely, returns the difference between the state of the IC instruction counter (_performance counter_ `0`) before and after executing `comp()`
  /// (see [Performance Counter](https://internetcomputer.org/docs/current/references/ic-interface-spec#system-api-performance-counter)).
  ///
  /// NB: `countInstructions(comp)` will _not_ account for any deferred garbage collection costs incurred by `comp()`.
  ///
  /// Example:
  /// ```motoko no-repl
  /// import IC "mo:base/ExperimentalInternetComputer";
  ///
  /// let count = IC.countInstructions(func() {
  ///   // ...
  /// });
  /// ```
  public func countInstructions(comp : () -> ()) : Nat64 {
    let init = Prim.performanceCounter(0);
    let pre = Prim.performanceCounter(0);
    comp();
    let post = Prim.performanceCounter(0);
    // performance_counter costs around 200 extra instructions, we perform an empty measurement to decide the overhead
    let overhead = pre - init;
    post - pre - overhead
  };

  /// Returns the current value of IC _performance counter_ `counter`.
  ///
  /// * Counter `0` is the _current execution instruction counter_, counting instructions only since the beginning of the current IC message.
  ///   This counter is reset to value `0` on shared function entry and every `await`.
  ///   It is therefore only suitable for measuring the cost of synchronous code.
  ///
  /// * Counter `1` is the _call context instruction counter_  for the current shared function call.
  ///   For replicated message executing, this excludes the cost of nested IC calls (even to the current canister).
  ///   For non-replicated messages, such as composite queries, it includes the cost of nested calls.
  ///   The current value of this counter is preserved across `awaits` (unlike counter `0`).
  ///
  /// * The function (currently) traps if `counter` >= 2.
  ///
  /// Consult [Performance Counter](https://internetcomputer.org/docs/current/references/ic-interface-spec#system-api-performance-counter) for details.
  ///
  /// Example:
  /// ```motoko no-repl
  /// import IC "mo:base/ExperimentalInternetComputer";
  ///
  /// let c1 = IC.performanceCounter(1);
  /// work();
  /// let diff : Nat64 = IC.performanceCounter(1) - c1;
  /// ```
  public let performanceCounter : (counter : Nat32) -> (value: Nat64) = Prim.performanceCounter;

  /// Returns the time (in nanoseconds from the epoch start) by when the update message should
  /// reply to the best effort message so that it can be received by the requesting canister.
  /// Queries and non-best-effort update messages return zero.
  public func replyDeadline() : Nat = Prim.nat64ToNat(Prim.replyDeadline());

}
