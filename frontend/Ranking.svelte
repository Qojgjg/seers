<script lang="ts">
  import { onMount } from "svelte"
  export let auth

  let response = []

  let getRanking = async () => {
    response = (await $auth.actor.readAllUsers()).sort(function (a, b) {
      var keyA = a.seerBalance,
        keyB = b.seerBalance
      if (keyA < keyB) return -1
      if (keyA > keyB) return 1
      return 0
    })
  }

  onMount(getRanking)
</script>

<div class="header">
  <h3>Top Forecasters</h3>
</div>

<div style="justify-content: center; display: flex;width: 100%">
  <div class="ranking">
    <div class="row">
      <div>Position</div>
      <div>Handle</div>
      <div># Markets</div>
      <div>Seers Balance</div>
    </div>
    {#each response as user, i}
      <div class="row">
        <div>#{i}</div>
        <div>{user.handle ? user.handle : user.id.slice(0, 11)}</div>
        <div>{user.markets.length}</div>
        <div>{user.seerBalance}</div>
      </div>
    {/each}
  </div>
</div>

<style>
  .row {
    display: flex;
    width: 100%;
  }
  .row > div {
    width: 25%;
    margin: 6px;
  }
  .ranking {
    display: flex;
    flex-wrap: wrap;
    padding: 1em;
    justify-content: start;
    min-width: 200px;
    max-width: 800px;
    background-color: rgb(25, 27, 31);
    border: 1px solid rgb(90, 58, 81);
    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);

    /* border: 2px solid rgb(25, 27, 31); */
    border-radius: 16px;
    justify-content: center;
    color: rgb(255, 255, 255);
  }
</style>
