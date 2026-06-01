cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1178"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1178/agentshield_0.2.1178_darwin_amd64.tar.gz"
      sha256 "fb624ed067965fe6d35ce452b1ce5bcf63df2ae941ae29e59584744dfca09baa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1178/agentshield_0.2.1178_darwin_arm64.tar.gz"
      sha256 "193ee69ee0aa0520cea729f07fe1644cfaad855ac5b5c8f4e2f88df033c977b5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1178/agentshield_0.2.1178_linux_amd64.tar.gz"
      sha256 "44408df68c06a27b5800872e4138321a38b72670d2d3ed0c72e307b1063bec4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1178/agentshield_0.2.1178_linux_arm64.tar.gz"
      sha256 "f1f92e21d35af8369d92c03d81923db5bb8a09618d33fc0f0b0f116faacb7dbd"
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
