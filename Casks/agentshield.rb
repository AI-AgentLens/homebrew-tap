cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.299"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.299/agentshield_0.2.299_darwin_amd64.tar.gz"
      sha256 "654b13ea3edd145f4ed4b773d1daa2ff6aed2971bf0422476f9682284e14a035"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.299/agentshield_0.2.299_darwin_arm64.tar.gz"
      sha256 "8746ad4741ac9f6ce9447dd980ef857f1591cfe841bc6f017b452c648e15d34b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.299/agentshield_0.2.299_linux_amd64.tar.gz"
      sha256 "ddad30a8a1e3fd35179f446c19f85a5584cde6fefbaa77a1f89562c8ab871023"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.299/agentshield_0.2.299_linux_arm64.tar.gz"
      sha256 "3bea495c541c9ecb9196e9ba989e893ab1b9b90e6a7a3b53306a6eeff3d4d475"
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
