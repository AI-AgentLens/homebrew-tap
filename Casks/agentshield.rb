cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.865"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.865/agentshield_0.2.865_darwin_amd64.tar.gz"
      sha256 "0f071ceb13523c32c95621ea7e0442a4f08ca5b06a9692214fe2fcc87bd58975"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.865/agentshield_0.2.865_darwin_arm64.tar.gz"
      sha256 "04698fa95cec1650fc3975fafe9cf2a94dbac685791b2c0b98a075915ef7bbc7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.865/agentshield_0.2.865_linux_amd64.tar.gz"
      sha256 "9c427a32502f2a0b5f35ef959bd116865942979b885e8dffbf4001940e55ebd0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.865/agentshield_0.2.865_linux_arm64.tar.gz"
      sha256 "4c3228f65f67f6a15dc81dd5b5ca08df5abf3f2ef54caf067125b4c763aa9a04"
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
