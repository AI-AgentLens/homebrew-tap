cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1482"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1482/agentshield_0.2.1482_darwin_amd64.tar.gz"
      sha256 "5ea99407a3353b3d389b38830d8df70eccf2ea141c093269bbbd1adfbe9bc52a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1482/agentshield_0.2.1482_darwin_arm64.tar.gz"
      sha256 "ec002d8d9e54d4115a7aa01e791d2f999040521c23de249a7c6fe08286e5b837"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1482/agentshield_0.2.1482_linux_amd64.tar.gz"
      sha256 "6a573414322749d37a6af2b549919f95ca1dc44636589a6d8b9b4232678386a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1482/agentshield_0.2.1482_linux_arm64.tar.gz"
      sha256 "04adf79025f071cdc446e190049cd43d81f0273419d61f4ba4a4454984496267"
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
