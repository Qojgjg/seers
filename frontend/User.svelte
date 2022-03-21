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

<div class="UserBody">
  {#if user}
    <div>
      <div style="margin-bottom: 10px">User Id: {user.id}.</div>
      <div style="margin-bottom: 10px">Balance: {user.seerBalance} seers.</div>
      Markets:
      <div style="display:flex; flex-direction: column; ">
        {#each user.markets as market}
          <a href="#/market/{market.marketId}">
            <div
              style="display:flex; align-items: center; align-content: center; flex-direction: row; gap: 10px; margin-top: 10px; padding: 3px; background-color: rgb(220 218 224 / 10%); "
            >
              <div style="">
                #{market.marketId}
              </div>
              <div style="">
                {market.marketTitle}
              </div>
              <div style="">
                {market.yesBalance} Yes
              </div>
              <div style="">
                {market.noBalance} No
              </div>
              <div style="">
                {market.shares} Shares
              </div>
              <div>
                <button
                  class=""
                  on:click={() => {
                    claimSeers(market.marketId)
                  }}>Claim</button
                >
              </div>
            </div>
          </a>
        {/each}
      </div>
    </div>
  {:else}
    <button
      class="demo-button"
      on:click={() => {
        createUserData()
      }}>Create User</button
    >
  {/if}
</div>

<style global>
  .demo-button {
    background: black;
    padding: 0 1em;
    margin-top: 1em;
    border-radius: 10px;
    font-size: 0.9em;
    height: 35px;
    outline: 0;
    border: 0;
    cursor: pointer;
    color: white;
  }
  .UserBody {
    display: flex;
    justify-content: center;
  }
</style>
