cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1027"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1027/agentshield_0.2.1027_darwin_amd64.tar.gz"
      sha256 "f07eaa6b9bd1508725157cf1f0832459b694db379bc26d94c71042abd5f62be8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1027/agentshield_0.2.1027_darwin_arm64.tar.gz"
      sha256 "fed31ecf6128d9d0215c53e7e91d535df5290850aca8990c627d80853b6884e8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1027/agentshield_0.2.1027_linux_amd64.tar.gz"
      sha256 "b8687aae31754361acdd9c874a0b12e24e78fc6ab099dbf2968ad0562f825902"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1027/agentshield_0.2.1027_linux_arm64.tar.gz"
      sha256 "34cad8da997968edc8f38e63303a02f62c488223778ee014a16ebc552b0277d5"
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
