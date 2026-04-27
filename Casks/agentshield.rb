cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.770"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.770/agentshield_0.2.770_darwin_amd64.tar.gz"
      sha256 "7f37c842f6d48f02825ae3500bee02b561c26371cb5c3d8d545556e22b9d8d1e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.770/agentshield_0.2.770_darwin_arm64.tar.gz"
      sha256 "95f10f3a233826b93a86d0e57fe6f65de3a31ea9eb5ec495f741b7647f87d62e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.770/agentshield_0.2.770_linux_amd64.tar.gz"
      sha256 "b2f2e512107c3e08cb0bd37d94a8c5b1c630f27d4a61e5b468176b5f02b9a10c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.770/agentshield_0.2.770_linux_arm64.tar.gz"
      sha256 "85a5639faf0caf7561b5bc5048d47409604dddbdfab76c31d271d5fa810cb236"
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
