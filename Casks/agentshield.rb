cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2359"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2359/agentshield_0.2.2359_darwin_amd64.tar.gz"
      sha256 "d17d254a93d9d6386db367cb7b80fe5ae9e9d3809e2816ed2d6fe51aae29410e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2359/agentshield_0.2.2359_darwin_arm64.tar.gz"
      sha256 "42e4b1d2d6b27c4d9560b2ba39af52023dcecd41f14198f4312de2e205a62c0d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2359/agentshield_0.2.2359_linux_amd64.tar.gz"
      sha256 "eb976734edf24f76d5a3784c6bd56962cc053571ab9d559908565051d237e203"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2359/agentshield_0.2.2359_linux_arm64.tar.gz"
      sha256 "ba7574c9b128df5db96c4b0a85a4dea0650f329c0219ec0e628a6d4ed054c372"
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
