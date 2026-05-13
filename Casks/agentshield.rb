cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.967"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.967/agentshield_0.2.967_darwin_amd64.tar.gz"
      sha256 "1c69567c89256d8a61bac2d823168b915b780986849235920fe8c44fd132689d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.967/agentshield_0.2.967_darwin_arm64.tar.gz"
      sha256 "1fe0538ab80dbd22ed2fc77de4332001ded6677341497d84249a68ddd08a7e2d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.967/agentshield_0.2.967_linux_amd64.tar.gz"
      sha256 "d98faab2a8f4352671a4c5fb642cd32a07a3687f8e7e82b6c90890051797b18f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.967/agentshield_0.2.967_linux_arm64.tar.gz"
      sha256 "cf0f0237f98b5d08ab1a568fa0c9afdd6a54ef8cb7b128d43a120527e7d07295"
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
