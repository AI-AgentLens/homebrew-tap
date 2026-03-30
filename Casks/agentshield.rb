cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.250"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.250/agentshield_0.2.250_darwin_amd64.tar.gz"
      sha256 "e744a0ee7f58a4ca09875d46b6d62cced73626ad2d290205ebcaaa74c70a6e66"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.250/agentshield_0.2.250_darwin_arm64.tar.gz"
      sha256 "aa0922dfcfa41e8a2096adfecef1fe47b9f890a306a60b66a2ce44e50594e6f0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.250/agentshield_0.2.250_linux_amd64.tar.gz"
      sha256 "903ad5921a54b0c4a2850d62821b16a44d27dba1fa150c753b207621016b51bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.250/agentshield_0.2.250_linux_arm64.tar.gz"
      sha256 "f5fc6fa96fdb128353a6fb593f6ffcdd7641fa578f64fc27d96c8861e26397f9"
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
