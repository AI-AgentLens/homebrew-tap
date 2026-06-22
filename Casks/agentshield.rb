cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1397"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1397/agentshield_0.2.1397_darwin_amd64.tar.gz"
      sha256 "4f3bb2114377db3ccbd822e02d9ac879ef63f3ed5ae370381ac8fb2657f05498"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1397/agentshield_0.2.1397_darwin_arm64.tar.gz"
      sha256 "94b6eb2124f5c5bd1115e52cbc9b36901fcc2ce3679f12f239e59de9f040fcde"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1397/agentshield_0.2.1397_linux_amd64.tar.gz"
      sha256 "96919485530e75f3b137b4c870fd5e8561b97d64d867c6e79221151396a9e8f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1397/agentshield_0.2.1397_linux_arm64.tar.gz"
      sha256 "6cca532ba576de8421223f13d34bb56fc0a33aa6947f8a363b0188b644b857bf"
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
