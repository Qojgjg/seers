<script lang="ts">
  import { onMount } from "svelte"

  import Header from "./Header.svelte"

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

  onMount(getUserData)
</script>

<Header />

<div class="UserBody">
  {#if user}
    <div>
      <div style="margin-bottom: 10px">User Id: {user.id}.</div>
      <div style="margin-bottom: 10px">Balance: {user.seerBalance} S.</div>
      Markets:
      <div style="display:flex; flex-direction: column; ">
        {#each user.markets as market}
          <div
            style="display:flex; flex-direction: row; gap: 10px; margin-top: 10px; padding: 3px; background-color:white; "
          >
            <div style="background-color:grey">
              #{market.marketId}
            </div>
            <div style="background-color:grey">
              <a href="#/market/{market.marketId}">
                {market.marketTitle}
              </a>
            </div>
            <div style="background-color:grey">
              {market.yesBalance} Yes
            </div>
            <div style="background-color:grey">
              {market.noBalance} No
            </div>
            <div style="background-color:grey">
              {market.shares} Shares
            </div>
            <div style="background-color:grey">
              {Object.keys(market.state)}
            </div>
          </div>
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
