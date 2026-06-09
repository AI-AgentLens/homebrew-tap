cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1265"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1265/agentshield_0.2.1265_darwin_amd64.tar.gz"
      sha256 "ca3c936c966332bd88ace067c68feb191aa1257eb6ea4684534bf49c3214b6e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1265/agentshield_0.2.1265_darwin_arm64.tar.gz"
      sha256 "e0f5da1a694e23abc0eb1fbcd5daa81e5e56ade67d5eec906521a1f2470f7c33"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1265/agentshield_0.2.1265_linux_amd64.tar.gz"
      sha256 "85db457077b27ea3c1cce00a7c072b6d6ef9f8fc3afc87e036c590f31005700a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1265/agentshield_0.2.1265_linux_arm64.tar.gz"
      sha256 "bf7718f329dadd02b91f63f8a6885a8a3ba1ffda4562f1b0918ea095984dae5c"
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
