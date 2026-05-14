cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.972"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.972/agentshield_0.2.972_darwin_amd64.tar.gz"
      sha256 "6877cc4e483e7ab7549a5fc34c93b348d302ae353b123845a1b56505a9e05e4f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.972/agentshield_0.2.972_darwin_arm64.tar.gz"
      sha256 "3523b62c076366ee79ff79f3c2d82da165bcd5f8af3e003acc3113ba8c58c5ed"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.972/agentshield_0.2.972_linux_amd64.tar.gz"
      sha256 "467f27fa8b71841269d7053b7a463a22c2fc6b120686198a4910f1bc78e8dd38"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.972/agentshield_0.2.972_linux_arm64.tar.gz"
      sha256 "909b9ea1b42df4b9077ebc73f35b448ce4b8b7ee89a4954864d9b6b23ab1f46c"
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
