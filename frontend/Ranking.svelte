<script lang="ts">
  import { faBreadSlice } from "@fortawesome/free-solid-svg-icons"

  import { onMount } from "svelte"
  export let auth

  let response = []

  let getRanking = async () => {
    response = (await $auth.actor.readAllUsers()).sort(function (a, b) {
      var keyA = a.expSeerBalance,
        keyB = b.expSeerBalance
      if (keyA < keyB) return 1
      if (keyA > keyB) return -1
      return 0
    })
    console.log(response)
  }

  onMount(getRanking)
</script>

<div class="header">
  <h3>Leaderboard</h3>
</div>

<div style="justify-content: center; display: flex;width: 100%">
  {#if response.length > 0}
    <div class="ranking">
      <div class="row">
        <div
          style="width: 20%;margin: 3px; font-size: 1.2em;margin-bottom: 1em"
        >
          #
        </div>
        <div
          style="width: 60%;margin: 3px; font-size: 1.2em;margin-bottom: 1em"
        >
          Handle
        </div>
        <!-- <div># Markets</div> -->
        <div
          style="width: 20%;margin: 3px; font-size: 1.2em;margin-bottom: 1em"
        >
          E(&Sigma)
        </div>
      </div>
      {#each response as user, i}
        <div class="row">
          <div style="width: 20%;margin: 3px">{i}</div>
          <div style="width: 60%;margin: 3px">
            <a href="/profile/{user.handle}">
              {user.handle ? user.handle : user.id.slice(0, 11)}
            </a>
          </div>
          <!-- <div>{user.markets.length}</div> -->
          <div style="width: 20%;margin: 3px">
            {Number(user.expBalances.seers).toFixed(2)}
          </div>
        </div>
      {/each}
    </div>
  {:else}
    Loading
  {/if}
</div>

<style>
  .row {
    display: flex;
    width: 100%;
  }
  .row:hover {
    background-color: hotpink;
  }
  .ranking {
    display: flex;
    flex-wrap: wrap;
    padding: 1em;
    justify-content: start;
    min-width: 50%;
    max-width: 800px;
    background-color: black;
    border: 1px solid rgb(90, 58, 81);
    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);

    /* border: 2px solid rgb(25, 27, 31); */
    border-radius: 16px;
    justify-content: center;
    color: rgb(255, 255, 255);
  }
</style>
