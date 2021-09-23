pragma solidity >=0.5.12;

import "./DssDeploy.t.base.sol";

contract DssDeployTest is DssDeployTestBase {
    function testDeploy() public {
        deploy();
    }

    function testFailMissingVat() public {
        dssDeploy.deployTaxation();
    }

    function testFailMissingTaxation() public {
        dssDeploy.deployVat();
        dssDeploy.deployUsdv()(99);
        dssDeploy.deployAuctions(address(gov));
    }

    function testFailMissingAuctions() public {
        dssDeploy.deployVat();
        dssDeploy.deployTaxation();
        dssDeploy.deployUsdv()(99);
        dssDeploy.deployLiquidator();
    }

    function testFailMissingLiquidator() public {
        dssDeploy.deployVat();
        dssDeploy.deployUsdv()(99);
        dssDeploy.deployTaxation();
        dssDeploy.deployAuctions(address(gov));
        dssDeploy.deployShutdown(address(gov), address(0x0), 10);
    }

    function testFailMissingEnd() public {
        dssDeploy.deployVat();
        dssDeploy.deployUsdv()(99);
        dssDeploy.deployTaxation();
        dssDeploy.deployAuctions(address(gov));
        dssDeploy.deployPause(0, address(authority));
    }

    function testJoinVLX() public {
        deploy();
        assertEq(vat.gem("VLX", address(this)), 0);
        wvlx.mint(1 ether);
        assertEq(wvlx.balanceOf(address(this)), 1 ether);
        wvlx.approve(address(vlxJoin), 1 ether);
        vlxJoin.join(address(this), 1 ether);
        assertEq(wvlx.balanceOf(address(this)), 0);
        assertEq(vat.gem("VLX", address(this)), 1 ether);
    }

    function testJoinGem() public {
        deploy();
        col.mint(1 ether);
        assertEq(col.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("COL", address(this)), 0);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        assertEq(col.balanceOf(address(this)), 0);
        assertEq(vat.gem("COL", address(this)), 1 ether);
    }

    function testExitVLX() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        vlxJoin.exit(address(this), 1 ether);
        assertEq(vat.gem("VLX", address(this)), 0);
    }

    function testExitGem() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        colJoin.exit(address(this), 1 ether);
        assertEq(col.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("COL", address(this)), 0);
    }

    function testFrobDrawUsdv() public {
        deploy();
        assertEq(usdv.balanceOf(address(this)), 0);
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);

        vat.frob("VLX", address(this), address(this), address(this), 0.5 ether, 60 ether);
        assertEq(vat.gem("VLX", address(this)), 0.5 ether);
        assertEq(vat.usdv(address(this)), mul(RAY, 60 ether));

        vat.hope(address(usdvJoin));
        usdvJoin.exit(address(this), 60 ether);
        assertEq(usdv.balanceOf(address(this)), 60 ether);
        assertEq(vat.usdv(address(this)), 0);
    }

    function testFrobDrawUsdvGem() public {
        deploy();
        assertEq(usdv.balanceOf(address(this)), 0);
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);

        vat.frob("COL", address(this), address(this), address(this), 0.5 ether, 20 ether);

        vat.hope(address(usdvJoin));
        usdvJoin.exit(address(this), 20 ether);
        assertEq(usdv.balanceOf(address(this)), 20 ether);
    }

    function testFrobDrawUsdvLimit() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        vat.frob("VLX", address(this), address(this), address(this), 0.5 ether, 100 ether); // 0.5 * 300 / 1.5 = 100 USDV max
    }

    function testFrobDrawUsdvGemLimit() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        vat.frob("COL", address(this), address(this), address(this), 0.5 ether, 20.454545454545454545 ether); // 0.5 * 45 / 1.1 = 20.454545454545454545 USDV max
    }

    function testFailFrobDrawUsdvLimit() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        vat.frob("VLX", address(this), address(this), address(this), 0.5 ether, 100 ether + 1);
    }

    function testFailFrobDrawUsdvGemLimit() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        vat.frob("COL", address(this), address(this), address(this), 0.5 ether, 20.454545454545454545 ether + 1);
    }

    function testFrobPaybackUsdv() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        vat.frob("VLX", address(this), address(this), address(this), 0.5 ether, 60 ether);
        vat.hope(address(usdvJoin));
        usdvJoin.exit(address(this), 60 ether);
        assertEq(usdv.balanceOf(address(this)), 60 ether);
        usdv.approve(address(usdvJoin), uint(-1));
        usdvJoin.join(address(this), 60 ether);
        assertEq(usdv.balanceOf(address(this)), 0);

        assertEq(vat.usdv(address(this)), mul(RAY, 60 ether));
        vat.frob("VLX", address(this), address(this), address(this), 0 ether, -60 ether);
        assertEq(vat.usdv(address(this)), 0);
    }

    function testFrobFromAnotherUser() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        vat.hope(address(user1));
        user1.doFrob(address(vat), "VLX", address(this), address(this), address(this), 0.5 ether, 60 ether);
    }

    function testFailFrobDust() public {
        deploy();
        wvlx.mint(100 ether); // Big number just to make sure to avoid unsafe situation
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 100 ether);

        this.file(address(vat), "VLX", "dust", mul(RAY, 20 ether));
        vat.frob("VLX", address(this), address(this), address(this), 100 ether, 19 ether);
    }

    function testFailFrobFromAnotherUser() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        user1.doFrob(address(vat), "VLX", address(this), address(this), address(this), 0.5 ether, 60 ether);
    }

    function testFailBite() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        vat.frob("VLX", address(this), address(this), address(this), 0.5 ether, 100 ether); // Maximun USDV

        cat.bite("VLX", address(this));
    }

    function testBite() public {
        deploy();
        this.file(address(cat), "VLX", "dunk", rad(200 ether)); // 200 USDV max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 USDV max on auction
        this.file(address(cat), "VLX", "chop", WAD);
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        vat.frob("VLX", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun USDV generated

        pipVLX.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("VLX");

        (uint ink, uint art) = vat.urns("VLX", address(this));
        assertEq(ink, 1 ether);
        assertEq(art, 200 ether);
        cat.bite("VLX", address(this));
        (ink, art) = vat.urns("VLX", address(this));
        assertEq(ink, 0);
        assertEq(art, 0);
    }

    function testBitePartial() public {
        deploy();
        this.file(address(cat), "VLX", "dunk", rad(200 ether)); // 200 USDV max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 USDV max on auction
        this.file(address(cat), "VLX", "chop", WAD);
        wvlx.mint(10 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 10 ether);
        vat.frob("VLX", address(this), address(this), address(this), 10 ether, 2000 ether); // Maximun USDV generated

        pipVLX.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("VLX");

        (uint ink, uint art) = vat.urns("VLX", address(this));
        assertEq(ink, 10 ether);
        assertEq(art, 2000 ether);
        cat.bite("VLX", address(this));
        (ink, art) = vat.urns("VLX", address(this));
        assertEq(ink, 9 ether);
        assertEq(art, 1800 ether);
    }

    function testFlip() public {
        deploy();
        this.file(address(cat), "VLX", "dunk", rad(200 ether)); // 200 USDV max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 USDV max on auction
        this.file(address(cat), "VLX", "chop", WAD);
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        vat.frob("VLX", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun USDV generated
        pipVLX.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("VLX");
        assertEq(vat.gem("VLX", address(vlxFlip)), 0);
        uint batchId = cat.bite("VLX", address(this));
        assertEq(vat.gem("VLX", address(vlxFlip)), 1 ether);
        wvlx.mint(10 ether);
        wvlx.transfer(address(user1), 10 ether);
        user1.doWvlxJoin(address(wvlx), address(vlxJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "VLX", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        wvlx.mint(10 ether);
        wvlx.transfer(address(user2), 10 ether);
        user2.doWvlxJoin(address(wvlx), address(vlxJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "VLX", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(vlxFlip));
        user2.doHope(address(vat), address(vlxFlip));

        user1.doTend(address(vlxFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(vlxFlip), batchId, 1 ether, rad(140 ether));
        user1.doTend(address(vlxFlip), batchId, 1 ether, rad(180 ether));
        user2.doTend(address(vlxFlip), batchId, 1 ether, rad(200 ether));

        user1.doDent(address(vlxFlip), batchId, 0.8 ether, rad(200 ether));
        user2.doDent(address(vlxFlip), batchId, 0.7 ether, rad(200 ether));
        hevm.warp(vlxFlip.ttl() - 1);
        user1.doDent(address(vlxFlip), batchId, 0.6 ether, rad(200 ether));
        hevm.warp(now + vlxFlip.ttl() + 1);
        user1.doDeal(address(vlxFlip), batchId);
    }

    function _flop() internal returns (uint batchId) {
        this.file(address(cat), "VLX", "dunk", rad(200 ether)); // 200 USDV max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 USDV max on auction
        this.file(address(cat), "VLX", "chop", WAD);
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);
        vat.frob("VLX", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun USDV generated
        pipVLX.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("VLX");
        uint48 eraBite = uint48(now);
        batchId = cat.bite("VLX", address(this));
        wvlx.mint(10 ether);
        wvlx.transfer(address(user1), 10 ether);
        user1.doWvlxJoin(address(wvlx), address(vlxJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "VLX", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        wvlx.mint(10 ether);
        wvlx.transfer(address(user2), 10 ether);
        user2.doWvlxJoin(address(wvlx), address(vlxJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "VLX", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(vlxFlip));
        user2.doHope(address(vat), address(vlxFlip));

        user1.doTend(address(vlxFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(vlxFlip), batchId, 1 ether, rad(140 ether));
        user1.doTend(address(vlxFlip), batchId, 1 ether, rad(180 ether));

        hevm.warp(now + vlxFlip.ttl() + 1);
        user1.doDeal(address(vlxFlip), batchId);

        vow.flog(eraBite);
        vow.heal(rad(180 ether));
        this.file(address(vow), "dump", 0.65 ether);
        this.file(address(vow), bytes32("sump"), rad(20 ether));
        batchId = vow.flop();
        (uint bid,,,,) = flop.bids(batchId);
        assertEq(bid, rad(20 ether));
        user1.doHope(address(vat), address(flop));
        user2.doHope(address(vat), address(flop));
    }

    function testFlop() public {
        deploy();
        uint batchId = _flop();
        user1.doDent(address(flop), batchId, 0.6 ether, rad(20 ether));
        hevm.warp(now + flop.ttl() - 1);
        user2.doDent(address(flop), batchId, 0.2 ether, rad(20 ether));
        user1.doDent(address(flop), batchId, 0.16 ether, rad(20 ether));
        hevm.warp(now + flop.ttl() + 1);
        uint prevGovSupply = gov.totalSupply();
        user1.doDeal(address(flop), batchId);
        assertEq(gov.totalSupply(), prevGovSupply + 0.16 ether);
        assertEq(vat.usdv(address(vow)), 0);
        assertEq(vat.sin(address(vow)) - vow.Sin() - vow.Ash(), 0);
        assertEq(vat.sin(address(vow)), 0);
    }

    function _flap() internal returns (uint batchId) {
        this.dripAndFile(address(jug), bytes32("VLX"), bytes32("duty"), uint(1.05 * 10 ** 27));
        wvlx.mint(0.5 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 0.5 ether);
        vat.frob("VLX", address(this), address(this), address(this), 0.1 ether, 10 ether);
        hevm.warp(now + 1);
        assertEq(vat.usdv(address(vow)), 0);
        jug.drip("VLX");
        assertEq(vat.usdv(address(vow)), rad(10 * 0.05 ether));
        this.file(address(vow), bytes32("bump"), rad(0.05 ether));
        batchId = vow.flap();

        (,uint lot,,,) = flap.bids(batchId);
        assertEq(lot, rad(0.05 ether));
        user1.doApprove(address(gov), address(flap));
        user2.doApprove(address(gov), address(flap));
        gov.transfer(address(user1), 1 ether);
        gov.transfer(address(user2), 1 ether);

        assertEq(usdv.balanceOf(address(user1)), 0);
        assertEq(gov.balanceOf(address(0)), 0);
    }

    function testFlap() public {
        deploy();
        uint batchId = _flap();

        user1.doTend(address(flap), batchId, rad(0.05 ether), 0.001 ether);
        user2.doTend(address(flap), batchId, rad(0.05 ether), 0.0015 ether);
        user1.doTend(address(flap), batchId, rad(0.05 ether), 0.0016 ether);

        assertEq(gov.balanceOf(address(user1)), 1 ether - 0.0016 ether);
        assertEq(gov.balanceOf(address(user2)), 1 ether);
        hevm.warp(now + flap.ttl() + 1);
        assertEq(gov.balanceOf(address(flap)), 0.0016 ether);
        user1.doDeal(address(flap), batchId);
        assertEq(gov.balanceOf(address(flap)), 0);
        user1.doHope(address(vat), address(usdvJoin));
        user1.doUsdvExit(address(usdvJoin), address(user1), 0.05 ether);
        assertEq(usdv.balanceOf(address(user1)), 0.05 ether);
    }

    function testEnd() public {
        deploy();
        this.file(address(cat), "VLX", "dunk", rad(200 ether)); // 200 USDV max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 USDV max on auction
        this.file(address(cat), "VLX", "chop", WAD);
        wvlx.mint(2 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 2 ether);
        vat.frob("VLX", address(this), address(this), address(this), 2 ether, 400 ether); // Maximun USDV generated
        pipVLX.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("VLX");
        uint batchId = cat.bite("VLX", address(this)); // The CDP remains unsafe after 1st batch is bitten
        wvlx.mint(10 ether);
        wvlx.transfer(address(user1), 10 ether);
        user1.doWvlxJoin(address(wvlx), address(vlxJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "VLX", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        col.mint(100 ether);
        col.approve(address(colJoin), 100 ether);
        colJoin.join(address(user2), 100 ether);
        user2.doFrob(address(vat), "COL", address(user2), address(user2), address(user2), 100 ether, 1000 ether);

        user1.doHope(address(vat), address(vlxFlip));
        user2.doHope(address(vat), address(vlxFlip));

        user1.doTend(address(vlxFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(vlxFlip), batchId, 1 ether, rad(140 ether));
        assertEq(vat.usdv(address(user2)), rad(860 ether));

        this.cage(address(end));
        end.cage("VLX");
        end.cage("COL");

        (uint ink, uint art) = vat.urns("VLX", address(this));
        assertEq(ink, 1 ether);
        assertEq(art, 200 ether);

        end.skip("VLX", batchId);
        assertEq(vat.usdv(address(user2)), rad(1000 ether));
        (ink, art) = vat.urns("VLX", address(this));
        assertEq(ink, 2 ether);
        assertEq(art, 400 ether);

        end.skim("VLX", address(this));
        (ink, art) = vat.urns("VLX", address(this));
        uint remainInkVal = 2 ether - 400 * end.tag("VLX") / 10 ** 9; // 2 VLX (deposited) - 400 USDV debt * VLX cage price
        assertEq(ink, remainInkVal);
        assertEq(art, 0);

        end.free("VLX");
        (ink,) = vat.urns("VLX", address(this));
        assertEq(ink, 0);

        (ink, art) = vat.urns("VLX", address(user1));
        assertEq(ink, 10 ether);
        assertEq(art, 1000 ether);

        end.skim("VLX", address(user1));
        end.skim("COL", address(user2));

        vow.heal(vat.usdv(address(vow)));

        end.thaw();

        end.flow("VLX");
        end.flow("COL");

        vat.hope(address(end));
        end.pack(400 ether);

        assertEq(vat.gem("VLX", address(this)), remainInkVal);
        assertEq(vat.gem("COL", address(this)), 0);
        end.cash("VLX", 400 ether);
        end.cash("COL", 400 ether);
        assertEq(vat.gem("VLX", address(this)), remainInkVal + 400 * end.fix("VLX") / 10 ** 9);
        assertEq(vat.gem("COL", address(this)), 400 * end.fix("COL") / 10 ** 9);
    }

    function testFlopEnd() public {
        deploy();
        uint batchId = _flop();
        this.cage(address(end));
        flop.yank(batchId);
    }

    function testFlopEndWithBid() public {
        deploy();
        uint batchId = _flop();
        user1.doDent(address(flop), batchId, 0.6 ether, rad(20 ether));
        assertEq(vat.usdv(address(user1)), rad(800 ether));
        this.cage(address(end));
        flop.yank(batchId);
        assertEq(vat.usdv(address(user1)), rad(820 ether));
    }

    function testFlapEnd() public {
        deploy();
        uint batchId = _flap();

        this.cage(address(end));
        flap.yank(batchId);
    }

    function testFlapEndWithBid() public {
        deploy();
        uint batchId = _flap();

        user1.doTend(address(flap), batchId, rad(0.05 ether), 0.001 ether);
        assertEq(gov.balanceOf(address(user1)), 1 ether - 0.001 ether);

        this.cage(address(end));
        flap.yank(batchId);

        assertEq(gov.balanceOf(address(user1)), 1 ether);
    }

    function testFireESM() public {
        deploy();
        gov.mint(address(user1), 10);

        user1.doESMJoin(address(gov), address(esm), 10);
        esm.fire();
    }

    function testDsr() public {
        deploy();
        this.dripAndFile(address(jug), bytes32("VLX"), bytes32("duty"), uint(1.1 * 10 ** 27));
        this.dripAndFile(address(pot), "dsr", uint(1.05 * 10 ** 27));
        wvlx.mint(0.5 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 0.5 ether);
        vat.frob("VLX", address(this), address(this), address(this), 0.1 ether, 10 ether);
        assertEq(vat.usdv(address(this)), mul(10 ether, RAY));
        vat.hope(address(pot));
        pot.join(10 ether);
        hevm.warp(now + 1);
        jug.drip("VLX");
        pot.drip();
        pot.exit(10 ether);
        assertEq(vat.usdv(address(this)), mul(10.5 ether, RAY));
    }

    function testFork() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);

        vat.frob("VLX", address(this), address(this), address(this), 1 ether, 60 ether);
        (uint ink, uint art) = vat.urns("VLX", address(this));
        assertEq(ink, 1 ether);
        assertEq(art, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("VLX", address(this), address(user1), 0.25 ether, 15 ether);

        (ink, art) = vat.urns("VLX", address(this));
        assertEq(ink, 0.75 ether);
        assertEq(art, 45 ether);

        (ink, art) = vat.urns("VLX", address(user1));
        assertEq(ink, 0.25 ether);
        assertEq(art, 15 ether);
    }

    function testFailFork() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);

        vat.frob("VLX", address(this), address(this), address(this), 1 ether, 60 ether);

        vat.fork("VLX", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testForkFromOtherUsr() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);

        vat.frob("VLX", address(this), address(this), address(this), 1 ether, 60 ether);

        vat.hope(address(user1));
        user1.doFork(address(vat), "VLX", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testFailForkFromOtherUsr() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);

        vat.frob("VLX", address(this), address(this), address(this), 1 ether, 60 ether);

        user1.doFork(address(vat), "VLX", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testFailForkUnsafeSrc() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);

        vat.frob("VLX", address(this), address(this), address(this), 1 ether, 60 ether);
        vat.fork("VLX", address(this), address(user1), 0.9 ether, 1 ether);
    }

    function testFailForkUnsafeDst() public {
        deploy();
        wvlx.mint(1 ether);
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 1 ether);

        vat.frob("VLX", address(this), address(this), address(this), 1 ether, 60 ether);
        vat.fork("VLX", address(this), address(user1), 0.1 ether, 59 ether);
    }

    function testFailForkDustSrc() public {
        deploy();
        wvlx.mint(100 ether); // Big number just to make sure to avoid unsafe situation
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 100 ether);

        this.file(address(vat), "VLX", "dust", mul(RAY, 20 ether));
        vat.frob("VLX", address(this), address(this), address(this), 100 ether, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("VLX", address(this), address(user1), 50 ether, 19 ether);
    }

    function testFailForkDustDst() public {
        deploy();
        wvlx.mint(100 ether); // Big number just to make sure to avoid unsafe situation
        wvlx.approve(address(vlxJoin), uint(-1));
        vlxJoin.join(address(this), 100 ether);

        this.file(address(vat), "VLX", "dust", mul(RAY, 20 ether));
        vat.frob("VLX", address(this), address(this), address(this), 100 ether, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("VLX", address(this), address(user1), 50 ether, 41 ether);
    }

    function testSetPauseAuthority() public {
        deploy();
        assertEq(address(pause.authority()), address(authority));
        this.setAuthority(address(123));
        assertEq(address(pause.authority()), address(123));
    }

    function testSetPauseDelay() public {
        deploy();
        assertEq(pause.delay(), 0);
        this.setDelay(5);
        assertEq(pause.delay(), 5);
    }

    function testSetPauseAuthorityAndDelay() public {
        deploy();
        assertEq(address(pause.authority()), address(authority));
        assertEq(pause.delay(), 0);
        this.setAuthorityAndDelay(address(123), 5);
        assertEq(address(pause.authority()), address(123));
        assertEq(pause.delay(), 5);
    }

    function testAuth() public {
        deployKeepAuth();

        // vat
        assertEq(vat.wards(address(dssDeploy)), 1);
        assertEq(vat.wards(address(vlcJoin)), 1);
        assertEq(vat.wards(address(colJoin)), 1);
        assertEq(vat.wards(address(cat)), 1);
        assertEq(vat.wards(address(jug)), 1);
        assertEq(vat.wards(address(spotter)), 1);
        assertEq(vat.wards(address(end)), 1);
        assertEq(vat.wards(address(pause.proxy())), 1);

        // cat
        assertEq(cat.wards(address(dssDeploy)), 1);
        assertEq(cat.wards(address(end)), 1);
        assertEq(cat.wards(address(pause.proxy())), 1);

        // vow
        assertEq(vow.wards(address(dssDeploy)), 1);
        assertEq(vow.wards(address(cat)), 1);
        assertEq(vow.wards(address(end)), 1);
        assertEq(vow.wards(address(pause.proxy())), 1);

        // jug
        assertEq(jug.wards(address(dssDeploy)), 1);
        assertEq(jug.wards(address(pause.proxy())), 1);

        // pot
        assertEq(pot.wards(address(dssDeploy)), 1);
        assertEq(pot.wards(address(pause.proxy())), 1);

        // usdv
        assertEq(usdv.wards(address(dssDeploy)), 1);

        // spotter
        assertEq(spotter.wards(address(dssDeploy)), 1);
        assertEq(spotter.wards(address(pause.proxy())), 1);

        // flap
        assertEq(flap.wards(address(dssDeploy)), 1);
        assertEq(flap.wards(address(vow)), 1);
        assertEq(flap.wards(address(pause.proxy())), 1);

        // flop
        assertEq(flop.wards(address(dssDeploy)), 1);
        assertEq(flop.wards(address(vow)), 1);
        assertEq(flop.wards(address(pause.proxy())), 1);

        // end
        assertEq(end.wards(address(dssDeploy)), 1);
        assertEq(end.wards(address(esm)), 1);
        assertEq(end.wards(address(pause.proxy())), 1);

        // flips
        assertEq(vlxFlip.wards(address(dssDeploy)), 1);
        assertEq(vlxFlip.wards(address(end)), 1);
        assertEq(vlxFlip.wards(address(pause.proxy())), 1);
        assertEq(colFlip.wards(address(dssDeploy)), 1);
        assertEq(colFlip.wards(address(end)), 1);
        assertEq(colFlip.wards(address(pause.proxy())), 1);

        // pause
        assertEq(address(pause.authority()), address(authority));
        assertEq(pause.owner(), address(0));

        // dssDeploy
        assertEq(address(dssDeploy.authority()), address(0));
        assertEq(dssDeploy.owner(), address(this));

        dssDeploy.releaseAuth();
        dssDeploy.releaseAuthFlip("VLX");
        dssDeploy.releaseAuthFlip("COL");
        assertEq(vat.wards(address(dssDeploy)), 0);
        assertEq(cat.wards(address(dssDeploy)), 0);
        assertEq(vow.wards(address(dssDeploy)), 0);
        assertEq(jug.wards(address(dssDeploy)), 0);
        assertEq(pot.wards(address(dssDeploy)), 0);
        assertEq(usdv.wards(address(dssDeploy)), 0);
        assertEq(spotter.wards(address(dssDeploy)), 0);
        assertEq(flap.wards(address(dssDeploy)), 0);
        assertEq(flop.wards(address(dssDeploy)), 0);
        assertEq(end.wards(address(dssDeploy)), 0);
        assertEq(vlxFlip.wards(address(dssDeploy)), 0);
        assertEq(colFlip.wards(address(dssDeploy)), 0);
    }
}
