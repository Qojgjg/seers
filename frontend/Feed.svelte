<script lang="ts">
  import { onMount } from "svelte"
  import Fa from "svelte-fa"
  import { Link } from "svelte-navigator"

  import {
    faComment,
    faHeart,
    faChartBar,
  } from "@fortawesome/free-regular-svg-icons"
  import { faRetweet, faPlus } from "@fortawesome/free-solid-svg-icons"
  import inf from "./assets/inf.gif"

  export let auth
  export let principal
  export let signIn

  let post = ""
  let errorResponse = ""
  let feed = []
  let processing = false
  let showBetForm = false
  let outcomes = [
    { id: 1, label: "Outcome 1", value: "" },
    { id: 2, label: "Outcome 2", value: "" },
  ]

  const submitPost = async () => {
    processing = true
    let initData = {
      id: 0,
      author: {
        principal,
        picture: "",
        handle: "",
        name: "",
      },
      content: post,
      postType: { post: null },
    }
    const r = await $auth.actor.submitPost(initData)
    console.log(r)
    processing = false
    post = ""
    getFeed()
  }

  const getFeed = async () => {
    feed = await $auth.actor.getFeed()
    feed = feed.reverse()
    console.log(feed)
  }

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
    // if (diff < 40) {
    //   return "half a minute ago"
    // }
    // if (diff < 60) {
    //   return "less than a minute ago"
    // }
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
        style="width: 100%; font-size: 1.3em; background: black;color:white;border: 0px solid rgb(90, 58, 81); padding: 5px; border-radius: 15px"
        placeholder={showBetForm ? "Ask a question..." : "What's happening?"}
      />
      {#if showBetForm}
        <div
          style="display:flex; flex-direction: column; width: 100%; height: fit-content; border: 1px solid rgb(47, 51, 54); border-radius: 16px; align-items:flex-end"
        >
          <div
            style="display:flex; width: 100%; height: fit-content; border: 0px solid rgb(47, 51, 54); align-items:flex-end"
          >
            <div
              style="display: flex; flex-direction:column; flex-grow: 1; justify-content:space-evenly"
            >
              {#each outcomes as outcome (outcome.id)}
                <div
                  style="height: 50px; border: 1px solid rgb(51, 54, 57); border-radius:4px; padding: 5px; margin: 15px"
                >
                  <input
                    bind:value={outcome.value}
                    type="text"
                    placeholder={outcome.label}
                    style="background: black; border: 0px; width: 100%; height: 100%; color:white; font-size: 1.2em;"
                  />
                </div>
              {/each}
            </div>

            <div
              style="width: 50px; height: 60px  ; display:flex; justify-content:center; align-items:flex-end; "
            >
              <div
                style="height: 100%"
                on:click={() => {
                  outcomes.push({
                    id: outcomes.length + 1,
                    label: `Outcome ${outcomes.length + 1}`,
                    value: "",
                  })
                  outcomes = outcomes
                  console.log(outcomes)
                }}
              >
                <Fa icon={faPlus} scale={1.3} />
              </div>
            </div>
          </div>
          <div
            style="display:flex; width: 100%; height: 70px; border-top: 1px solid rgb(47, 51, 54); align-items:flex-end;"
          >
            <div
              style="display:flex; width: 100%; height: 100%; padding: 0px 5px;"
            >
              <div
                style="width: 50%; height: 100%; border-right: 1px solid rgb(47, 51, 54); display:flex; flex-direction:column; justify-content:center; padding: 0px 10px"
              >
                <label for="start" style="width: 100%; color:grey"
                  >Start date:</label
                >

                <input
                  type="date"
                  id="start"
                  name="trip-start"
                  value="2022-01-01"
                  min="2022-01-01"
                  max="2050-01-01"
                  style="background: black; color:grey; border: 0px; font-size: 1.5em"
                />
              </div>
              <div
                style="width: 50%; height: 100%; border-right: 0px solid rgb(47, 51, 54); display:flex; flex-direction:column; justify-content:center; padding: 0px 10px"
              >
                <label for="start" style="width: 100%; color:grey"
                  >End date:</label
                >

                <input
                  type="date"
                  id="end"
                  name="trip-end"
                  value="2022-01-01"
                  min="2022-01-01"
                  max="2050-01-01"
                  style="background: black; color:grey; border: 0px; font-size: 1.5em"
                />
              </div>
            </div>
          </div>
        </div>
      {/if}
      <div style="display:flex">
        <div
          style="display:flex; text-align:center; align-items:center; width: 50px"
          on:click={() => {
            showBetForm = showBetForm ? false : true
          }}
        >
          <Fa icon={faChartBar} scale={1.2} />
        </div>

        {#if principal === ""}
          <div
            style="display:flex; text-align:end; justify-content:end; flex-grow: 1"
          >
            <button class="btn-grad" on:click={signIn}>Login</button>
            <div style="text-align:end;color:red">
              {errorResponse}
            </div>
          </div>
        {:else if processing}
          <div
            style="display:flex; text-align:end; justify-content:end; flex-grow: 1"
          >
            <button
              class="btn-grad"
              on:click={() => 0}
              style="width: 100px; overflow:hidden"
            >
              <img
                src={inf}
                alt="inf"
                style="width: 150px; height: 400%; margin: -100%;"
              />
            </button>
            <div style="text-align:end;color:red">
              {errorResponse}
            </div>
          </div>
        {:else}
          <div
            style="display:flex; text-align:end; justify-content:end; flex-grow: 1"
          >
            <button class="btn-grad" on:click={submitPost}>Post</button>
            <div style="text-align:end;color:red">
              {errorResponse}
            </div>
          </div>
        {/if}
      </div>
    </div>
  </div>
  <div
    style="width: 100%; display:flex; justify-content:center; flex-direction:column; align-items:center; gap: 10px"
  >
    <div class="rowUser">
      {#each feed as item, i}
        {#if i != feed.length - 1}
          {#if item.citing.length > 0}
            <div
              style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 1px solid grey"
            >
              <div style="padding: 5px; margin: 5px; height: 100%">
                <a href={`/profile/${item.author.principal}`}>
                  <img
                    src={item.author.picture}
                    alt="avatar"
                    style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
                  />
                </a>
              </div>
              <div
                style="flex-grow: 1; justify-content: start; text-align:start"
              >
                <div style="display:flex; gap: 5px;">
                  <div>
                    <a href={`/profile/${item.author.principal}`}
                      >{item.author.name}</a
                    >
                  </div>
                  <div style="color:grey">
                    <a
                      href={`/profile/${item.author.principal}`}
                      style="color:grey"
                    >
                      @{item.author.handle}
                    </a>
                  </div>
                  <div style="color:grey">
                    - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                  </div>
                  <div style="color:grey">- Retweeted</div>
                </div>
                <Link to={`/profile/post/${item.id}#main`} style="width: 100%">
                  <div style="width: 100%; text-align:start; padding: 5px 0px">
                    {item.citing[0].content}
                  </div>
                </Link>
                <div
                  style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
                >
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faComment} /></div>
                    <div>{item.replies.length}</div>
                  </div>
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faRetweet} /></div>
                    <div>0</div>
                  </div>
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faHeart} /></div>
                    <div>{item.likes.length}</div>
                  </div>
                </div>
              </div>
            </div>
          {:else}
            <div
              style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 1px solid grey"
            >
              <div style="padding: 5px; margin: 5px; height: 100%">
                <a href={`/profile/${item.author.principal}`}>
                  <img
                    src={item.author.picture}
                    alt="avatar"
                    style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
                  />
                </a>
              </div>
              <div
                style="flex-grow: 1; justify-content: start; text-align:start"
              >
                <div style="display:flex; gap: 5px;">
                  <div>
                    <a href={`/profile/${item.author.principal}`}
                      >{item.author.name}</a
                    >
                  </div>
                  <div style="color:grey">
                    <a
                      href={`/profile/${item.author.principal}`}
                      style="color:grey"
                    >
                      @{item.author.handle}
                    </a>
                  </div>
                  <div style="color:grey">
                    - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                  </div>
                </div>
                <Link to={`/profile/post/${item.id}#main`} style="width: 100%">
                  <div style="width: 100%; text-align:start; padding: 5px 0px">
                    {item.content}
                  </div>
                </Link>
                <div
                  style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
                >
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faComment} /></div>
                    <div>{item.replies.length}</div>
                  </div>
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faRetweet} /></div>
                    <div>0</div>
                  </div>
                  <div style="width: 50px; display:flex; gap: 15px">
                    <div><Fa icon={faHeart} /></div>
                    <div>{item.likes.length}</div>
                  </div>
                </div>
              </div>
            </div>
          {/if}
        {:else if item.citing.length > 0}
          <div
            style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center;"
          >
            <div style="padding: 5px; margin: 5px; height: 100%">
              <a href={`/profile/${item.author.principal}`}>
                <img
                  src={item.author.picture}
                  alt="avatar"
                  style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
                />
              </a>
            </div>
            <div style="flex-grow: 1; justify-content: start; text-align:start">
              <div style="display:flex; gap: 5px;">
                <div>
                  <a href={`/profile/${item.author.principal}`}
                    >{item.author.name}</a
                  >
                </div>
                <div style="color:grey">
                  <a
                    href={`/profile/${item.author.principal}`}
                    style="color:grey"
                  >
                    @{item.author.handle}
                  </a>
                </div>
                <div style="color:grey">
                  - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                </div>
                <div style="color:grey">- Retweeted</div>
              </div>
              <Link to={`/profile/post/${item.id}`} style="width: 100%">
                <div style="width: 100%; text-align:start; padding: 5px 0px">
                  {item.citing.content}
                </div>
              </Link>
              <div
                style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:gray"
              >
                <div style="width: 50px; display:flex; gap: 15px;">
                  <div><Fa icon={faComment} /></div>
                  <div>{item.replies.length}</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faRetweet} /></div>
                  <div>0</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faHeart} /></div>
                  <div>{item.likes.length}</div>
                </div>
              </div>
            </div>
          </div>
        {:else}
          <div
            style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center;"
          >
            <div style="padding: 5px; margin: 5px; height: 100%">
              <a href={`/profile/${item.author.principal}`}>
                <img
                  src={item.author.picture}
                  alt="avatar"
                  style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
                />
              </a>
            </div>
            <div style="flex-grow: 1; justify-content: start; text-align:start">
              <div style="display:flex; gap: 5px;">
                <div>
                  <a href={`/profile/${item.author.principal}`}
                    >{item.author.name}</a
                  >
                </div>
                <div style="color:grey">
                  <a
                    href={`/profile/${item.author.principal}`}
                    style="color:grey"
                  >
                    @{item.author.handle}
                  </a>
                </div>
                <div style="color:grey">
                  - {parseTwitterDate(parseInt(item.createdAt) / 1_000_000)}
                </div>
              </div>
              <Link to={`/profile/post/${item.id}`} style="width: 100%">
                <div style="width: 100%; text-align:start; padding: 5px 0px">
                  {item.content}
                </div>
              </Link>
              <div
                style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:gray"
              >
                <div style="width: 50px; display:flex; gap: 15px;">
                  <div><Fa icon={faComment} /></div>
                  <div>{item.replies.length}</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faRetweet} /></div>
                  <div>0</div>
                </div>
                <div style="width: 50px; display:flex; gap: 15px">
                  <div><Fa icon={faHeart} /></div>
                  <div>{item.likes.length}</div>
                </div>
              </div>
            </div>
          </div>
        {/if}
      {/each}
    </div>
  </div>
</div>
