/* eslint-disable no-invalid-this */

$(document).ready(function () {
  const voteButton = $("#vote_button"),
        delegationsButton = $("#delegations-button"),
        delegationCallouts = $(".delegation-callout"),
        delegationCalloutsMessage = $(".delegation-callout-message"),
        delegationDialog = $("#delegations-modal"),
        delegationVoteButtons = $(".delegation-vote-button"),
        delegationField = $("#decidim_consultations_delegation_id"),
        voteDialog = $("#question-vote-modal");

  delegationsButton.click(function () {
    delegationDialog.foundation("open");
  });

  delegationVoteButtons.click(function () {
    voteDialog.foundation("open");
    delegationField.val($(this).data("delegation-id"));
    delegationCalloutsMessage.text($(this).data("delegation-granter-name"));
    delegationCallouts.removeClass("is-hidden");
  });

  voteButton.click(function () {
    delegationCallouts.addClass("is-hidden");
  });
});
