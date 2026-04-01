cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.284"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.284/agentshield_0.2.284_darwin_amd64.tar.gz"
      sha256 "857ec44784a4ec705f680bd1aeec0f9c13c813d11af88015834c123fb6fb478c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.284/agentshield_0.2.284_darwin_arm64.tar.gz"
      sha256 "b202e487be0335e74b9c24c192046ba0de7b7254cd037abcccf027a8a269e09d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.284/agentshield_0.2.284_linux_amd64.tar.gz"
      sha256 "bae7f9a069a45aa335b137f260c41a1ead3d298fd125193a912e420b20b63cec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.284/agentshield_0.2.284_linux_arm64.tar.gz"
      sha256 "75235844f9d4b1adbc4d029609a0b8e77a4861b3269c5d6eddd1c91bf1e8c866"
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
