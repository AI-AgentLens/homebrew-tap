cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.597"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.597/agentshield_0.2.597_darwin_amd64.tar.gz"
      sha256 "a0fb40abcf5ec0b6ae9d3e3c7761c35fd1bffdd611ca4752bf8fce609d35b71a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.597/agentshield_0.2.597_darwin_arm64.tar.gz"
      sha256 "5017269f86d2d48560af49a2f813a8f4d3af0198b93acdf7905903c8ebc66a72"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.597/agentshield_0.2.597_linux_amd64.tar.gz"
      sha256 "95d798345447a91e58a324ae3b51133cb762c64432391f0f71f49f1c9c08b8be"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.597/agentshield_0.2.597_linux_arm64.tar.gz"
      sha256 "bb2bbb2163f703d9a0b0757a0e5a1da025e2708a55a8b2f9ae4d1eb8ea62e497"
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
