cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.258"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.258/agentshield_0.2.258_darwin_amd64.tar.gz"
      sha256 "bb9af45ef626dde983543f52dd921712c45537a6e6530fcc0e76918e737063ba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.258/agentshield_0.2.258_darwin_arm64.tar.gz"
      sha256 "bb644e02a3aa48bc9cca93c3c391ecd76b68f59d3f43cd0c97db9985f2ba2c49"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.258/agentshield_0.2.258_linux_amd64.tar.gz"
      sha256 "8563a72897bb8e57747b65c61e1b180a01cc2331e625f841bb0ecbba5b216601"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.258/agentshield_0.2.258_linux_arm64.tar.gz"
      sha256 "0e5fea2db14b832c4b3c9f073dcfae1b6f9e3fe92e7b88531d8879d997bb9001"
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
