<script lang="ts">
  import { onMount } from "svelte"
  import Fa from "svelte-fa"
  import { faComment, faHeart } from "@fortawesome/free-regular-svg-icons"
  import { faRetweet } from "@fortawesome/free-solid-svg-icons"

  export let auth
  export let principal
  export let signIn

  let post = ""
  let errorResponse = ""
  let feed = []

  const submitPost = async () => {
    const r = await $auth.actor.submitPost(post)
    post = ""
    getFeed()
  }

  const getFeed = async () => {
    feed = await $auth.actor.getFeed()
  }

  function parseTwitterDate(tdate) {
    var system_date = new Date(tdate)
    var user_date = new Date()

    var diff = Math.floor((Number(user_date) - Number(system_date)) / 1000)
    if (diff <= 1) {
      return "just now"
    }
    if (diff < 20) {
      return diff + " seconds ago"
    }
    if (diff < 40) {
      return "half a minute ago"
    }
    if (diff < 60) {
      return "less than a minute ago"
    }
    if (diff <= 90) {
      return "one minute ago"
    }
    if (diff <= 3540) {
      return Math.round(diff / 60) + " minutes ago"
    }
    if (diff <= 5400) {
      return "1 hour ago"
    }
    if (diff <= 86400) {
      return Math.round(diff / 3600) + " hours ago"
    }
    if (diff <= 129600) {
      return "1 day ago"
    }
    if (diff < 604800) {
      return Math.round(diff / 86400) + " days ago"
    }
    if (diff <= 777600) {
      return "1 week ago"
    }
    return "on " + system_date
  }

  onMount(getFeed)
</script>

<div
  style="justify-content: center; display: flex;width: 100%; margin-top: 20px; flex-direction:column; align-items:center; gap: 20px"
>
  <div class="rowUser">
    <div style="width: 100%; margin: 0px; padding: 5px">
      <textarea
        bind:value={post}
        rows="3"
        style="width: 100%; font-size: 1.3em; background: rgb(25, 27, 31);color:white;border: 0px solid rgb(90, 58, 81); padding: 5px; border-radius: 15px"
        placeholder="Please share your insights. You can use markdown."
      />
      {#if principal === ""}
        <div style="display:flex; text-align:end; justify-content:end;">
          <button class="btn-grad" on:click={signIn}>Login</button>
          <div style="text-align:end;color:red">
            {errorResponse}
          </div>
        </div>
      {:else}
        <div style="display:flex; text-align:end; justify-content:end;">
          <button class="btn-grad" on:click={submitPost}>Post</button>
          <div style="text-align:end;color:red">
            {errorResponse}
          </div>
        </div>
      {/if}
    </div>
  </div>
  <div
    style="width: 100%; display:flex; justify-content:center; flex-direction:column; align-items:center; gap: 10px"
  >
    <div class="rowUser">
      {#each feed as item, i}
        {#if i != feed.length - 1}
          <div
            style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 1px solid grey"
          >
            <div style="padding: 5px; margin: 5px; height: 100%">
              <img
                src={item.author.picture}
                alt="avatar"
                style="width: 50px; object-fit: cover; border-radius: 50%"
              />
            </div>
            <div style="flex-grow: 1; justify-content: start; text-align:start">
              <div style="display:flex; gap: 5px;">
                <div>{item.author.name}</div>
                <div style="color:grey">@{item.author.handle}</div>
                <div style="color:grey">
                  - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                </div>
              </div>
              <div style="width: 100%; text-align:start; padding: 5px 0px">
                {item.content}
              </div>
              <div
                style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
              >
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faComment} /></div>
                  <div>0</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faRetweet} /></div>
                  <div>0</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faHeart} /></div>
                  <div>0</div>
                </div>
              </div>
            </div>
          </div>
        {:else}
          <div
            style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center;"
          >
            <div style="padding: 5px; margin: 5px; height: 100%">
              <img
                src={item.author.picture}
                alt="avatar"
                style="width: 50px; object-fit: cover; border-radius: 50%"
              />
            </div>
            <div style="flex-grow: 1; justify-content: start; text-align:start">
              <div style="display:flex; gap: 5px;">
                <div>{item.author.name}</div>
                <div style="color:grey">@{item.author.handle}</div>
                <div style="color:grey">
                  - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                </div>
              </div>
              <div style="width: 100%; text-align:start; padding: 5px 0px">
                {item.content}
              </div>
              <div
                style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:gray"
              >
                <div style="width: 50px; display:flex; gap: 15px;">
                  <div><Fa icon={faComment} /></div>
                  <div>0</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faRetweet} /></div>
                  <div>0</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faHeart} /></div>
                  <div>0</div>
                </div>
              </div>
            </div>
          </div>
        {/if}
      {/each}
    </div>
  </div>
</div>
