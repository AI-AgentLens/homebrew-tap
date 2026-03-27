cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.133"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.133/agentshield_0.2.133_darwin_amd64.tar.gz"
      sha256 "fdb94d4995fe286d5fa7bb324ea62ac4122b581a07a301e783581b37afe9c0ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.133/agentshield_0.2.133_darwin_arm64.tar.gz"
      sha256 "6746c804279e65e95822872a980be1858182ccc7611e3e3eedbc1057cd994417"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.133/agentshield_0.2.133_linux_amd64.tar.gz"
      sha256 "48d26eecf0979d143836f476071a73cb146ed96f3563f821e18bb89f1004f75c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.133/agentshield_0.2.133_linux_arm64.tar.gz"
      sha256 "84714b45a66e470f330132efef81c82a4b21d7737dd3806f86325fca2e31ca25"
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
