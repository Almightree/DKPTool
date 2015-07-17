local currentItem -- the current item or nil if no auction is running
local bids = {} -- bids on the current item
local prefix = "[SimpleDKP] " -- prefix for chat messages

-- default values for saved variables/options
SimpleDKP_Channel = "GUILD" -- The chat channel to use
SimpleDKP_AuctionTime = 30 -- the time (in seconds) for an auction
SimpleDKP_MinBid = 15 -- the minimum amount of DKP you have to bid
SimpleDKP_ACL = {} -- the access control list

local startAuction, endAuction, placeBid, cancelAuction, onEvent

do
local auctionAlreadyRunning = "There is already and auction running! (on %s)"
local startingAuction = prefix.."Starting auction for item %s, please place your bids by whispering me. Remaining time: %d seconds."
local auctionProgress = prefix.."Time remaining for %s: %d seconds."

function startAuction(item, starter)
	if currentItem then
		local msg = auctionAlreadyRunning:format(currentItem)
		if starter then
			SendChatMessage(msg, "WHISPER", nil, starter)
		else
			print(msg)
		end
	else
		currentItem = item
		SendChatMessage(startingAuction:format(item, SimpleDKP_AuctionTime),SimpleDKP_Channel)
		if SimpleDKP_AuctionTime > 30 then
			SimpleTimingLib_Schedule(SimpleDKP_AuctionTime - 30, SendChatMessage, auctionProgress:format(item, 30), SimpleDKP_Channel)
		end
		if SimpleDKP_AuctionTime > 15 then
			SimpleTimingLib_Schedule(SimpleDKP_AuctionTime - 15, SendChatMessage, auctionProgress:format(item, 15), SimpleDKP_Channel)
		end
		if SimpleDKP_AuctionTime > 5 then
			SimpleTimingLib_Schedule(SimpleDKP_AuctionTime - 5, SendChatMessage, auctionProgress:format(item, 5), SimpleDKP_Channle)
		end
		SimpleTimingLib_Schedule(SimpleDKP_AuctionTime, endAuction)
	end
end
end

do
local noBids = prefix.."No one wants to have %s :("
local wonItemFor = prefix.."%s won %s for %d DKP."
local pleaseRoll = prefix.."%s bid %d on %s, please roll!"
local highestBidders = prefix.."%d. %s bid %d DKP."

local function sortBids(v1, v2)
	return v1.bid > v2.bid
end
function endAuction()
	table.sort(bids, sortBids)
	if #bids == 0 then -- case 1: no bid at all
		SendChatMessage(noBids:format(currentItem), SimpleDKP_Channel)