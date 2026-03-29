cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.194"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.194/agentshield_0.2.194_darwin_amd64.tar.gz"
      sha256 "d3ded61ac4fffd89264dddfcf1578cf344da27cd5d79ef470b099b9f53450c1d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.194/agentshield_0.2.194_darwin_arm64.tar.gz"
      sha256 "8c5434f53a134a179f26c3349df5a88e6554f3f3999d61498cfe45f22dcc499c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.194/agentshield_0.2.194_linux_amd64.tar.gz"
      sha256 "005ef80013bf64175fa22d6c08ccd1e787f5f64907158e723993fa359b967f9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.194/agentshield_0.2.194_linux_arm64.tar.gz"
      sha256 "b3b339490f98ed16d599c46c5e3e5338e2d544788f626045c0541c40456041bc"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
