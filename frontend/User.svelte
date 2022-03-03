<script lang="ts">
  import { onMount } from "svelte"

  import Header from "./Header.svelte"

  export let auth
  export let principal

  let user

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
      Markets:
      <div style="display:flex; flex-direction: column; ">
        <div style="display:flex; flex-direction: row; gap: 10px">
          <div>Title</div>
          <div>Yes Balance</div>
          <div>No Balance</div>
          <div>Shares</div>
        </div>
        {#each user.markets as market}
          <div style="display:flex; flex-direction: row; gap: 10px">
            <a href="#/market/{market.marketId}">
              {market.marketTitle}
            </a>
            <div>
              {market.yesBalance}
            </div>
            <div>
              {market.noBalance}
            </div>
            <div>
              {market.shares}
            </div>
          </div>
        {/each}
      </div>
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
