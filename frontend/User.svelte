<script lang="ts">
  import { onMount } from "svelte"

  import Header from "./Header.svelte"

  export let auth
  export let principal

  let user
  let newMarketTitle
  let newMarketDesc
  let yesDeposit
  let noDeposit
  let endDate

  let createMarket = async () => {
    yesDeposit = parseInt(yesDeposit)
    noDeposit = parseInt(noDeposit)
    const liquidity = yesDeposit + noDeposit
    const yesProb = Math.floor((yesDeposit * 100) / liquidity)
    const noProb = 100 - yesProb
    const marketInitData = {
      title: newMarketTitle,
      description: newMarketDesc,
      yesProb: yesProb,
      noProb: noProb,
      liquidity: liquidity,
      endDate: Date.parse(endDate) * 1_000_000,
    }
    await $auth.actor.createMarket(marketInitData)
  }

  let getUserData = async () => {
    user = await $auth.actor.getUser(principal)
    console.log(user)
  }

  onMount(getUserData)
</script>

<Header />

<div class="UserBody">
  {#if user}
    <div>
      <div>User Id: {user.id}.</div>
      <div>Balance: {user.seerBalance} seers.</div>
      <div>
        Markets:
        {#each user.markets as market}
          <div>
            id {market.marketId} | {market.marketTitle} | {market.yesBalance} $yes
            | {market.noBalance}
            $no | {market.shares} shares
          </div>
        {/each}
      </div>
    </div>
    <div>
      <div style="">
        <h6 style="">Create new market</h6>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div>Title:</div>
        <div><input bind:value={newMarketTitle} /></div>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div>Description:</div>
        <div><textarea bind:value={newMarketDesc} /></div>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div>Yes deposit:</div>
        <div>$<input bind:value={yesDeposit} /></div>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div>No deposit:</div>
        <div>$<input bind:value={noDeposit} /></div>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div>End date:</div>
        <div><input bind:value={endDate} /></div>
      </div>

      <button class="demo-button" on:click={createMarket}>Create Market</button>
    </div>
  {:else}
    loading...
  {/if}
</div>

<style global>
  .UserBody {
    display: flex;
    justify-content: center;
  }
</style>
