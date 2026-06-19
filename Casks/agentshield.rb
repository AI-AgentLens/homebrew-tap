cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1376"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1376/agentshield_0.2.1376_darwin_amd64.tar.gz"
      sha256 "c106cfc7b731eb21e7ecb84b177fbed36fe239f6c2cef9dd0eba59d21dc43f68"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1376/agentshield_0.2.1376_darwin_arm64.tar.gz"
      sha256 "3375050f1c74d24b827b7786c7cecb4f8910fd8555a4abd93271b7c7163097f9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1376/agentshield_0.2.1376_linux_amd64.tar.gz"
      sha256 "b4d685772bae037f53c364b796178a6b47fc471bf4a101a71b70ecbec37416e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1376/agentshield_0.2.1376_linux_arm64.tar.gz"
      sha256 "04c78dc195f8c7d0835e51d22032729974dd35a470ec8cb122e5620deac8c177"
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
