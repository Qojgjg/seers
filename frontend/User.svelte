<script lang="ts">
  import { faBreadSlice } from "@fortawesome/free-solid-svg-icons"

  import { onMount } from "svelte"
  import { identity, text } from "svelte/internal"
  import ListMarkets from "./ListMarkets.svelte"
  import ViewMarket from "./ViewMarket.svelte"
  export let auth
  export let principal

  let user = null
  let createLabel = "Create User"
  let handle = ""
  let response = null
  let errorResponse = ""
  let errorRefresh = ""
  let refreshLabel = "Refresh"
  let isGetting = false

  const splitCamelCaseToString = (s) => {
    return s
      .split(/(?=[A-Z])/)
      .map((p) => {
        return p[0].toUpperCase() + p.slice(1)
      })
      .join(" ")
  }

  const getMarketLabel = (id, idx) => {
    let market = user.markets.find((m) => m.marketId == id)
    return market.labels[idx]
  }

  let getUserData = async () => {
    isGetting = true
    user = await $auth.actor.getUserResult(principal)
    isGetting = false
    if (user) {
      user = user[0]
      user.markets = user.markets.sort(function (a, b) {
        var keyA = Number(a.marketId),
          keyB = Number(b.marketId)
        if (keyA < keyB) return -1
        if (keyA > keyB) return 1
        return 0
      })
      user.txs = user.txs.reverse()
    }
    console.log(user)
  }

  let createUserData = async () => {
    createLabel = "Processing..."
    errorResponse = ""
    response = await $auth.actor.createUserResult(handle)
    if (response["err"]) {
      errorResponse =
        "Error: " +
        splitCamelCaseToString(Object.keys(response["err"]).toString())
    } else {
      user = response["ok"]
    }
    createLabel = "Create User"
    console.log(user)
  }

  let refreshUser = async () => {
    refreshLabel = "Processing..."
    response = await $auth.actor.refreshUser()
    if (response["err"]) {
      errorRefresh =
        "Error: " +
        splitCamelCaseToString(Object.keys(response["err"]).toString())
    } else {
      errorRefresh = ""
      user = response["ok"]
    }
    refreshLabel = "Refresh"
  }

  onMount(getUserData)
</script>

<div class="header">
  <h3>Profile</h3>
</div>

<div style="justify-content: center; display: flex;width: 100%">
  <div class="rowUser">
    {#if user}
      <div style="margin-bottom: 10px; width: 100%; text-align:center">
        Welcome {user.handle}! ♡
      </div>
      <div style="margin-bottom: 10px; width: 100%; text-align:center">
        Balance: {Number(user.seerBalance).toFixed(2)} Σ
      </div>
      <div style="margin-bottom: 10px; width: 100%; text-align:center">
        Expected Balance: {Number(user.expSeerBalance).toFixed(2)} Σ
      </div>
      <div style="margin-bottom: 10px; width: 100%; text-align:center">
        <button class="demo-button" on:click={refreshUser}
          >{refreshLabel}</button
        >
        <div style="text-align:center;color:red">
          {errorRefresh}
        </div>
      </div>
      {#if user.markets.length}
        <div style="display:flex; flex-direction: column;width: 100%">
          Portfolio:
          {#each user.markets as market}
            {#if market.used == false}
              <a href="#/market/{market.marketId}">
                <div
                  style="border-radius: 5px; display:flex; align-items: center; align-content: center; flex-direction: column; gap: 10px; margin-top: 10px; padding: 10px; background-color: rgb(220 218 224 / 10%); "
                >
                  <div style="width: 100%; display: flex">
                    <div style="width:fit-content; margin-right: 10px">
                      #{market.marketId}:
                    </div>
                    <div style="width: auto">
                      {market.marketTitle}
                    </div>
                  </div>
                  <div style="width: 100%">
                    {#each market.labels as label, i}
                      {#if market.balances[i] > 0.0}
                        {label +
                          ": " +
                          Number(market.balances[i]).toFixed(2) +
                          "  "}
                      {/if}
                    {/each}
                  </div>
                </div>
              </a>
            {/if}
          {/each}
        </div>
      {/if}
      {#if user.txs.length}
        <div
          style="display:flex; flex-direction: column;width: 100%; margin-top: 20px"
        >
          Transactions:
          {#each user.txs as tx, i}
            <div
              style="border-radius: 5px; display:flex; align-items: center; align-content: center; flex-direction: column; gap: 10px; margin-top: 10px; padding: 10px; background-color: rgb(220 218 224 / 10%); "
            >
              <div style="width: 100%; display: flex; flex-wrap: wrap">
                <div style="width:fit-content; margin-right: 10px">
                  #{user.txs.length - i}:
                </div>
                <div style="width: auto; margin-right: 10px;">
                  Market {tx.marketId}
                </div>
                <div
                  style="width: auto;margin-right: 10px; text-transform:capitalize"
                >
                  From {tx.src.length > 0
                    ? getMarketLabel(tx.marketId, tx.src).slice(0, 30)
                    : "seers"}
                </div>
                <div
                  style="width: auto;margin-right: 10px;text-transform:capitalize"
                >
                  To {tx.dest.length > 0
                    ? getMarketLabel(tx.marketId, tx.dest).slice(0, 30)
                    : "seers"}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Price {(tx.seerSent / tx.seerRecv).toFixed(2)}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Received {tx.seerRecv.toFixed(2)}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Spent {tx.seerSent.toFixed(2)}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Fee {tx.fee.toFixed(2)}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Date {new Date(
                    parseInt(tx.timestamp) / 1_000_000,
                  ).toLocaleDateString()}
                </div>
              </div>
            </div>
          {/each}
        </div>
      {/if}
    {:else if isGetting}
      Loading
    {:else}
      <div style="display: flex; align-items: center; flex-direction: column">
        <div style="padding: 10px; margin: 10px">Handle:</div>
        <input
          bind:value={handle}
          style="align-items: center; width:100%; height: 30px"
        />
        <div style="width: 100%;display:flex; justify-content:center">
          <button
            class="demo-button"
            on:input={() => (errorResponse = "")}
            on:click={() => {
              createUserData()
            }}>{createLabel}</button
          >
        </div>
        <br />
        <div style="text-align:center;color:red">
          {errorResponse}
        </div>
      </div>
    {/if}
  </div>
</div>

<style global>
  .rowUser {
    display: flex;
    flex-wrap: wrap;
    padding: 1em;
    justify-content: start;
    min-width: 200px;
    max-width: 800px;
    width: 80%;
    background-color: rgb(25, 27, 31);
    border: 1px solid rgb(90, 58, 81);
    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);

    /* border: 2px solid rgb(25, 27, 31); */
    border-radius: 16px;
    justify-content: center;
    color: rgb(255, 255, 255);
  }

  .demo-button {
    height: 40px;
    background: rgb(33, 114, 229);
    box-shadow: rgb(0 0 0 / 8%) 0px 6px 10px;
    padding: 0 1em;
    margin: 1em;
    border-radius: 10px;
    font-size: 0.9em;
    outline: 0;
    border: 0;
    cursor: pointer;
    color: white;
    max-width: 150px;
    white-space: normal;
  }

  .demo-button:hover {
    background: rgb(25, 108, 224);
  }
</style>
