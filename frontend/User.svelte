<script lang="ts">
  import { onMount } from "svelte"
  export let auth
  export let principal

  let user

  let getUserData = async () => {
    user = await $auth.actor.getUserResult(principal)
    if (user) {
      user = user[0]
    }
    console.log(user)
  }

  let createUserData = async () => {
    user = await $auth.actor.createUserResult()
    console.log(user)
  }

  let claimSeers = async (marketId) => {
    let tokens = await $auth.actor.claimTokens(marketId)
    console.log("Tokens claimed: " + tokens)
  }

  onMount(getUserData)
</script>

<div class="header">
  <h3>Profile Data</h3>
</div>

<div class="rowUser">
  {#if user}
    <div
      style="margin-bottom: 10px; justify-content:center; width: 100%; text-align:center"
    >
      Id: {user.id}.
    </div>
    <div
      style="margin-bottom: 10px; justify-content: center; width: 100%;text-align:center"
    >
      Balance: {user.seerBalance} seers.
    </div>
    {#if user.markets.length}
      <div style="display:flex; flex-direction: column;">
        Markets:
        {#each user.markets as market}
          <a href="#/market/{market.marketId}">
            <div
              style="display:flex; align-items: center; align-content: center; flex-direction: row; gap: 10px; margin-top: 10px; padding: 3px; background-color: rgb(220 218 224 / 10%); "
            >
              <div style="">
                #{market.marketId}.
              </div>
              <div style="">
                {market.marketTitle}
              </div>
              <div style="">
                {market.balances} tokens.
              </div>
              <div style="">
                {market.shares} shares.
              </div>
              <div>
                <button
                  class="demo-button"
                  on:click={() => {
                    claimSeers(market.marketId)
                  }}>Claim</button
                >
              </div>
            </div>
          </a>
        {/each}
      </div>
    {/if}
  {:else}
    <div class="rowUser">
      <button
        class="demo-button"
        on:click={() => {
          createUserData()
        }}>Create User</button
      >
    </div>
  {/if}
</div>

<style global>
  .rowUser {
    display: flex;
    flex-wrap: wrap;
    padding: 10px;
    justify-content: center;
  }

  .demo-button {
    background: rgb(33, 114, 229);
    box-shadow: rgb(0 0 0 / 8%) 0px 6px 10px;
    padding: 0 1em;
    margin-top: 1em;
    border-radius: 10px;
    font-size: 0.9em;
    height: 35px;
    outline: 0;
    border: 0;
    cursor: pointer;
    color: white;
    max-width: 150px;
  }

  .demo-button:hover {
    background: rgb(25, 108, 224);
  }
</style>
