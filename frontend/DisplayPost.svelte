<script lang="ts">
  import Fa from "svelte-fa"

  import { faComment, faHeart } from "@fortawesome/free-regular-svg-icons"
  import {
    faRetweet,
    faEllipsis,
    faHeart as faSolidHeart,
  } from "@fortawesome/free-solid-svg-icons"
  import inf from "./assets/inf.gif"

  export let auth
  export let principal
  export let signIn
  export let post
  export let isThread = false
  export let doNotShowBorder = false
  export let isMain = false
  export let doNotShowParent = false

  let amount = 0.5
  let errorResponse = ""
  let processing = false
  let anonImage =
    "https://static.wikia.nocookie.net/codegeass/images/c/c0/Zero.jpg"

  function parseTwitterDate(tdate) {
    var system_date = new Date(tdate)
    var user_date = new Date()

    var diff = Math.floor((Number(user_date) - Number(system_date)) / 1000)
    if (diff <= 1) {
      return "now"
    }
    if (diff < 60) {
      return diff + "s"
    }
    if (diff <= 90) {
      return "1m"
    }
    if (diff <= 3540) {
      return Math.round(diff / 60) + "m"
    }
    if (diff <= 5400) {
      return "1h"
    }
    if (diff <= 86400) {
      return Math.round(diff / 3600) + "h"
    }
    if (diff <= 129600) {
      return "1d"
    }
    if (diff < 604800) {
      return Math.round(diff / 86400) + "d"
    }
    if (diff <= 777600) {
      return "1w"
    }
    return "on " + system_date
  }

  const getPost = async () => {
    post = await $auth.actor.getThread(Number(post.id))
    if ("ok" in post) {
      console.log(post)
      post = post["ok"].main
    } else {
      console.log(post["err"])
    }
  }

  const submitDelete = async (postId) => {
    const resp = await $auth.actor.submitDelete(Number(postId))
    if ("err" in resp) {
      errorResponse = Object.keys(resp["err"]).toString()
    } else {
      getPost()
    }
  }

  const submitBuy = async (marketId, selected, amount) => {
    processing = true
    selected = selected === undefined ? 0 : selected
    const resp = await $auth.actor.buyOutcome(
      marketId,
      Number(amount),
      selected,
      true,
    )
    if ("err" in resp) {
      errorResponse = Object.keys(resp["err"]).toString()
    } else {
      getPost()
      amount = 0.1
    }
    processing = false
    console.log(resp)
  }

  const submitLike = async (postId) => {
    const resp = await $auth.actor.submitLike(Number(postId))
    if ("err" in resp) {
      errorResponse = resp["err"]
    } else {
      getPost()
    }
    console.log(resp)
  }

  const submitRetweet = async () => {
    const resp = await $auth.actor.submitRetweet(Number(post.id))
    if ("err" in resp) {
      errorResponse = resp["err"]
    } else {
      getPost()
    }
    console.log(resp)
  }
</script>

{#if isMain}
  <div
    id="main"
    style="padding: 0px 0px 0px 0px; width: 100%; border-top: 0px solid grey; "
  >
    <div
      style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 5px 0px; flex-direction:row; align-items:center; font-size: 1.2em; "
    >
      <div style="padding: 0px 0px; margin: 0px 5px; height: 100%;">
        <a href={`/profile/${post?.author.handle}`}>
          <img
            src={post?.author.picture ? post?.author.picture : anonImage}
            alt="avatar"
            style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
          />
        </a>
      </div>
      <div
        style="display:flex; flex-direction:column; height: 100%; flex-grow: 1"
      >
        <a href={`/profile/${post?.author.handle}`}
          >{post?.author.name ? post.author.name : ""}</a
        >
        <a href={`/profile/${post?.author.handle}`} style="color:grey">
          @{post?.author.handle ? post.author.handle : ""}
        </a>
      </div>
      <!-- <div style="width: 100%; display:flex; justify-content:end"> -->
      <div class="menu-button-elli">
        <div class="dropdown">
          <button class="dropbtn"><Fa icon={faEllipsis} /></button>
          {#if post?.author.principal == principal}
            <div class="dropdown-content">
              <a href={`/post/${post.id}/edit`}>Edit</a>
              <button
                on:click={submitDelete(post.id)}
                style="unset:all; background:black;color:white; padding: 12px 16px; font-size:16px; cursor:pointer"
                >Delete</button
              >
            </div>
          {:else}
            <div class="dropdown-content">
              <a href="#">Follow</a>
              <a href="#">Block</a>
            </div>
          {/if}
        </div>
        <!-- </div> -->
      </div>
    </div>
    <div style="flex-grow: 1; justify-content: start; text-align:start">
      <a href={`/post/${post?.id}#main`} style="width: 100%">
        <div
          style="width: 100%; text-align:start; padding: 0px 0px; border-bottom: 0px solid grey;"
        >
          <div style="padding: 10px 0px; font-size: 1.2em">
            {post?.content ? post.content : ""}
          </div>
        </div>
      </a>
      {#if post && post.market.length > 0}
        <div>
          {#each post.market[0].labels as label, i}
            <div
              style="width: 100%; display:flex; cursor:pointer; margin: 0; padding: 0;"
            >
              <div
                style={`background: ${
                  post.market[0].selected == i ||
                  (post.market[0].selected === undefined && i == 0)
                    ? "#FFDC00"
                    : "#39CCCC"
                }; width: ${
                  post.market[0].probabilities[i] * 100.0
                }%; padding: 5px 0px 0px 0px; margin: 2px 0px; border: 0px solid black; border-radius: 5px 5px 5px 5px; color:black;`}
              >
                <div
                  style={`background: ${
                    post.market[0].selected == i ||
                    (post.market[0].selected === undefined && i == 0)
                      ? "#FFDC00"
                      : "#39CCCC"
                  }; width: 100px; border: 0px solid black; color:black; text-align:right`}
                >
                  <button
                    style="all:unset; width: 100%"
                    on:click={() => {
                      post.market[0].selected = i
                    }}
                  >
                    {label}
                  </button>
                </div>
              </div>
              <div
                style="flex-grow: 1; justify-content:flex-end; text-align:end; padding: 5px"
              >
                {post.market[0].probabilities[i].toFixed(2)}
                {"seers" in post.market[0].collateralType ? "Σ" : "ICP"}
              </div>
            </div>
          {/each}
          <div
            style="display:flex; text-align:end; justify-content:start; flex-grow: 1"
          >
            {#if processing}
              <input bind:value={amount} />
              <button
                class="btn-grad"
                style="background: black;width: 100px; margin: 15px 0px; color:white;overflow:hidden;"
                on:click={() => {
                  if (principal === "") {
                    signIn()
                  } else {
                    submitBuy(
                      post.market[0].id,
                      post.market[0].selected,
                      amount,
                    )
                  }
                }}
              >
                <img
                  src={inf}
                  alt="inf"
                  style="width: 150px; height: 400%; margin: -100%;"
                />
              </button>
              <input
                style="color: rgb(255, 255, 255); background-color: black; font-size: 1.2em; font-family: 'Roboto Mono', monospace; border: 0px; padding: 0px 5px; margin: 0px 15px; width: 50px"
                bind:value={amount}
              />
              <div
                style="display:flex; text-align:center; align-items:center; padding: 0px 5px"
              >
                {"seers" in post.market[0].collateralType ? "Σ" : "ICP"}
              </div>
            {:else}
              <button
                class="btn-grad"
                style="background: black; padding: 5px; margin: 15px 0px; color: white"
                on:click={() => {
                  if (principal === "") {
                    signIn()
                  } else {
                    submitBuy(
                      post.market[0].id,
                      post.market[0].selected,
                      amount,
                    )
                  }
                }}>Buy</button
              >
              <input
                style="color: rgb(255, 255, 255); background-color: black; font-size: 1.2em; font-family: 'Roboto Mono', monospace; border: 0px; padding: 0px 5px; margin: 0px 15px; width: 50px"
                bind:value={amount}
              />
              <div
                style="display:flex; text-align:center; align-items:center; padding: 0px 5px"
              >
                {"seers" in post.market[0].collateralType ? "Σ" : "ICP"}
              </div>
            {/if}
            <div style="text-align:center;color:red">
              {errorResponse}
            </div>
          </div>
        </div>
      {:else if post && post.image.length > 0}
        <div>
          <img
            src={post.image[0]}
            alt="main"
            style="width: 95%; border-radius: 15px; object-fit:cover"
          />
        </div>
      {/if}
      <div style="color:grey; padding: 5px 0px;border-bottom: 1px solid grey;">
        {new Date(parseInt(post?.createdAt) / 1_000_000).toDateString()}
        -
        {new Date(parseInt(post?.createdAt) / 1_000_000).toLocaleTimeString()}
      </div>
      <div
        style="width: 100%; display:flex; gap: 30px; padding: 10px 0px; color:grey; border-bottom: 1px solid grey;"
      >
        <div style="width: 100px; display:flex; gap: 15px">
          <div style="color:white">{post?.retweeters.length}</div>
          <div>Retweets</div>
        </div>
        <div style="width: 100px; display:flex; gap: 15px">
          <div style="color:white">{post?.likes.length}</div>
          <div>Likes</div>
        </div>
      </div>
      <div
        style="width: 100%; display:flex; gap: 30px; padding: 10px 0px; color:grey; border-bottom: 1px solid grey;"
      >
        <div style="width: 50px; display:flex; gap: 15px">
          <div><Fa icon={faComment} /></div>
        </div>
        <div style="width: 50px; display:flex; gap: 15px">
          <div><Fa icon={faRetweet} /></div>
        </div>
        <div style="width: 50px; display:flex; gap: 15px">
          <div>
            <button
              on:click={() => {
                if (principal === "") signIn()
                else {
                  const like = {
                    author: {
                      principal,
                      handle: "dummy",
                      name: "dummy",
                      picture: "dummy",
                    },
                    createdAt: Date.now(),
                  }
                  const liked = post.likes.find(
                    (like) => like.author.principal == principal,
                  )

                  console.log(liked)

                  console.log(post.likes.length)
                  if (liked) {
                    post.likes = post.likes.filter(
                      (like) => like.author.principal != principal,
                    )
                  } else {
                    post.likes.push(like)
                    post.likes = post.likes
                  }

                  console.log(post.likes.length)
                  submitLike(post.id)
                }
              }}
              style={`color:${
                post?.likes.find((like) => like.author.principal == principal)
                  ? "#e81c4f"
                  : ""
              }`}
              class="like-bt"
            >
              <Fa
                icon={post?.likes.find(
                  (like) => like.author.principal == principal,
                )
                  ? faSolidHeart
                  : faHeart}
              />
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
{:else}
  <div
    style={`display:flex; justify-content:start; text-align:start; width: 100%; padding: 0px 0px; flex-direction:column; align-items:center; border-bottom: ${
      isThread || doNotShowBorder ? 0 : 1
    }px solid grey`}
  >
    {#if post && post.isRetweet.length > 0}
      <div
        style="display:flex; color:grey; font-size: 0.8em; justify-content:start; width: 100%"
      >
        <div style="padding: 15px 0px 0px 40px">
          <Fa icon={faRetweet} />
        </div>
        <div style="padding: 15px 0px 0px 5px">
          <a href={`/profile/${post.isRetweet[0].handle}`} style="color:grey">
            by @{post.isRetweet[0].handle}
          </a>
        </div>
      </div>
    {:else if post && !doNotShowParent && post.parent.length > 0}
      <div
        style="display:flex; color:grey; font-size: 0.8em; justify-content:start; width: 100%"
      >
        <div style="padding: 15px 0px 0px 40px">
          <Fa icon={faComment} />
        </div>
        <div style="padding: 15px 0px 0px 5px; color:grey">
          <a href={`/post/${post.parent[0].id}`} style="color:grey">
            Replying to @{post.parent[0].author.handle}
          </a>
        </div>
      </div>
    {/if}
    <div style="display:flex; width: 100%; padding: 10px; margin: 5px">
      <div
        style="display:flex; flex-direction:column; padding: 0px; margin: 5px; height: 100%"
      >
        <a href={`/profile/${post.author.handle}`}>
          <img
            src={post.author.picture ? post.author.picture : anonImage}
            alt="avatar"
            style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%; padding: 0px 0px 0px 0px;margin: 10px 0px 0px 0px;"
          />
        </a>
        {#if isThread}
          <div style="display:flex; justify-content:center; flex-grow: 1">
            <div style="width: 2px; height: 100%; background:rgb(51, 54, 57)">
              &nbsp;
            </div>
          </div>
        {/if}
      </div>
      <div
        style="flex-grow: 1; justify-content: start; text-align:start; padding: 15px 0px;"
      >
        <div style="display:flex; gap: 5px;">
          <div>
            <a href={`/profile/${post.author.handle}`}>{post.author.name}</a>
          </div>
          <div style="color:grey">
            <a href={`/profile/${post.author.handle}`} style="color:grey">
              @{post.author.handle}
            </a>
          </div>
          <div style="color:grey">
            - {parseTwitterDate(parseInt(post.createdAt) / 1_000_000)}
          </div>
        </div>
        <a href={`/post/${post.id}#main`} style="width: 50px">
          <div style="width: 100%; text-align:start; padding: 15px 0px">
            {#if post.retweet.length > 0}
              {post.retweet[0].content}
            {:else}
              {post.content}
            {/if}
          </div>
        </a>
        {#if post && post.market.length > 0}
          <div>
            {#each post.market[0].labels as label, i}
              <div
                style="width: 100%; display:flex; cursor:pointer; margin: 0; padding: 0;"
              >
                <div
                  style={`background: ${
                    post.market[0].selected == i ||
                    (post.market[0].selected === undefined && i == 0)
                      ? "#FFDC00"
                      : "#39CCCC"
                  }; width: ${
                    post.market[0].probabilities[i] * 100.0
                  }%; padding: 5px 5px 5px 5px; margin: 2px 2px; border: 0px solid black; border-radius: 5px 5px 5px 5px; color:black;`}
                >
                  <div
                    style={`background: ${
                      post.market[0].selected == i ||
                      (post.market[0].selected === undefined && i == 0)
                        ? "#FFDC00"
                        : "#39CCCC"
                    }; width: 100px; border: 0px solid black;  color:black; text-align:right`}
                  >
                    <button
                      style="all:unset; width: 100%"
                      on:click={() => {
                        post.market[0].selected = i
                      }}
                    >
                      {label}
                    </button>
                  </div>
                </div>
                <div
                  style="flex-grow: 1; justify-content:flex-end; text-align:end;padding: 5px"
                >
                  {post.market[0].probabilities[i].toFixed(2)}
                  {"seers" in post.market[0].collateralType ? "Σ" : "ICP"}
                </div>
              </div>
            {/each}
            <div
              style="display:flex; text-align:end; justify-content:start; flex-grow: 1"
            >
              {#if processing}
                <button
                  class="btn-grad"
                  style="background: black;width: 100px; margin: 15px 0px; color:white;overflow:hidden;"
                  on:click={() => {
                    if (principal === "") {
                      signIn()
                    } else {
                      submitBuy(
                        post.market[0].id,
                        post.market[0].selected,
                        amount,
                      )
                    }
                  }}
                >
                  <img
                    src={inf}
                    alt="inf"
                    style="width: 150px; height: 400%; margin: -100%;"
                  />
                </button>
                <input
                  style="color: rgb(255, 255, 255); background-color: black; font-size: 1em; font-family: 'Roboto Mono', monospace; border: 0px; padding: 0px 5px; margin: 0px 15px; width: 50px"
                  bind:value={amount}
                />
                <div
                  style="display:flex; text-align:center; align-items:center; padding: 0px 5px"
                >
                  {"seers" in post.market[0].collateralType ? "Σ" : "ICP"}
                </div>
              {:else}
                <button
                  class="btn-grad"
                  style="background: black; padding: 0px 15px; margin: 15px 0px; color: white"
                  on:click={() => {
                    if (principal === "") {
                      signIn()
                    } else {
                      submitBuy(
                        post.market[0].id,
                        post.market[0].selected,
                        amount,
                      )
                    }
                  }}>Buy</button
                >
                <input
                  style="color: rgb(255, 255, 255); background-color: black; font-size: 1em; font-family: 'Roboto Mono', monospace; border: 0px; padding: 0px 5px; margin: 0px 15px; width: 50px"
                  bind:value={amount}
                />
                <div
                  style="display:flex; text-align:center; align-items:center; padding: 0px 5px"
                >
                  {"seers" in post.market[0].collateralType ? "Σ" : "ICP"}
                </div>
              {/if}
              <div style="text-align: center;color:red">
                {errorResponse}
              </div>
            </div>
          </div>
        {:else if post && post.image.length > 0}
          <div>
            <img
              src={post.image[0]}
              alt="main"
              style="width: 95%; border-radius: 15px; object-fit:cover"
            />
          </div>
        {/if}
        <div
          style="width: 200px; display:flex; padding: 5px 0px; color:grey; justify-content:space-between"
        >
          <a href={`/post/${post.id}#main`} style="color:grey">
            <div style="display:flex; gap: 15px;">
              <div>
                <button class="reply-bt"><Fa icon={faComment} /></button>
              </div>
              {#if post.replies.length > 0}<div>{post.replies.length}</div>{/if}
            </div>
          </a>
          <div style="width: fit-content; display:flex; gap: 15px">
            <div>
              <button
                class="retweet-bt"
                on:click={() => {
                  if (principal === "") {
                    signIn()
                  } else {
                    submitRetweet()
                  }
                }}><Fa icon={faRetweet} /></button
              >
            </div>
            {#if post.retweeters.length > 0}<div>
                {post.retweeters.length}
              </div>{/if}
          </div>
          <div style="width: 50px; display:flex; gap: 15px">
            <div>
              <button
                on:click={() => {
                  if (principal === "") {
                    signIn()
                  } else {
                    const like = {
                      author: {
                        principal,
                        handle: "dummy",
                        name: "dummy",
                        picture: "dummy",
                      },
                      createdAt: Date.now(),
                    }
                    const liked = post.likes.find(
                      (like) => like.author.principal == principal,
                    )

                    console.log(liked)

                    console.log(post.likes.length)
                    if (liked) {
                      post.likes = post.likes.filter(
                        (like) => like.author.principal != principal,
                      )
                    } else {
                      post.likes.push(like)
                      post.likes = post.likes
                    }

                    console.log(post.likes.length)
                    submitLike(post.id)
                  }
                }}
                style={`color:${
                  post?.likes.find((like) => like.author.principal == principal)
                    ? "#e81c4f"
                    : ""
                }`}
                class="like-bt"
                ><Fa
                  icon={post?.likes.find(
                    (like) => like.author.principal == principal,
                  )
                    ? faSolidHeart
                    : faHeart}
                /></button
              >
            </div>
            {#if post.likes.length > 0}
              <div
                style={`color:${
                  post?.likes.find((like) => like.author.principal == principal)
                    ? "#e81c4f"
                    : ""
                }`}
              >
                {post.likes.length}
              </div>
            {/if}
          </div>
        </div>
      </div>
      <div class="menu-button-elli">
        <div class="dropdown">
          <button class="dropbtn"><Fa icon={faEllipsis} /></button>
          {#if post?.author.principal == principal}
            <div class="dropdown-content">
              <a href={`/post/${post.id}/edit`}>Edit</a>
              <button
                on:click={submitDelete(post.id)}
                style="unset:all; background:black;color:white; padding: 12px 16px; font-size:16px; cursor:pointer"
                >Delete</button
              >
            </div>
          {:else}
            <div class="dropdown-content">
              <a href="#">Follow/Unfollow</a>
              <a href="#">Block/Unblock</a>
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>
{/if}

<style>
  .menu-button-elli {
    background-color: black;
    display: flex;
    width: 20px;
    justify-content: start;
    text-align: start;
    padding: 0px 0px;
    cursor: pointer;
  }

  .menu-button-elli:hover {
    color: #1da1f2;
  }

  .like-bt {
    all: unset;
    cursor: pointer;
  }
  .like-bt:hover {
    color: #e81c4f;
  }

  .retweet-bt {
    all: unset;
    cursor: pointer;
  }
  .retweet-bt:hover {
    color: #19cf86;
  }

  .reply-bt {
    all: unset;
    cursor: pointer;
  }
  .reply-bt:hover {
    color: #1da1f2;
  }
  /* Dropdown Button */
  .dropbtn {
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: black;
    color: grey;
    margin: 0px;
    padding: 0px;
    font-size: 16px;
    border: none;
  }

  /* The container <div> - needed to position the dropdown content */
  .dropdown {
    position: relative;
    display: inline-block;
  }

  /* Dropdown Content (Hidden by Default) */
  .dropdown-content {
    display: none;
    position: absolute;
    background-color: black;
    min-width: 160px;
    margin-top: -40px;
    margin-left: -120px;
    box-shadow: 0px 8px 16px 0px rgba(0, 0, 0, 0.2);
    z-index: 1;
  }

  /* Links inside the dropdown */
  .dropdown-content a {
    color: white;
    padding: 12px 16px;
    text-decoration: none;
    display: block;
  }

  /* Change color of dropdown links on hover */
  .dropdown-content a:hover {
    background-color: black;
  }

  /* Show the dropdown menu on hover */
  .dropdown:hover .dropdown-content {
    display: block;
  }

  /* Change the background color of the dropdown button when the dropdown content is shown */
  .dropdown:hover .dropbtn {
    background-color: black;
  }
</style>
