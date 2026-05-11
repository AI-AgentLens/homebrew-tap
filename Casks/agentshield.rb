cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.947"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.947/agentshield_0.2.947_darwin_amd64.tar.gz"
      sha256 "e3af1c72a724c8d3bfe5583208b79af41c602d5af654a7cb122763821334af8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.947/agentshield_0.2.947_darwin_arm64.tar.gz"
      sha256 "ef25a4d315a12124b7fd8398f04a6e39592fac60fd7258d2722bce341e0728be"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.947/agentshield_0.2.947_linux_amd64.tar.gz"
      sha256 "a8f8517677bf99dad82933cca5c2abb780a3262ab3bf0e76cd17ea5f4a109be7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.947/agentshield_0.2.947_linux_arm64.tar.gz"
      sha256 "3c9381c7f24a1a51f5898722d2d4243fafe589616b64ceefdcc78f6c7808122c"
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
